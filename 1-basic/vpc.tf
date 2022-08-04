locals {
  # CIDR Math
  cidrprefix = join(".", slice(split(".", var.cidr), 0, 2))

  # AZ Calculation
  azs               = [for azletter in var.region_azs : "${var.region}${azletter}"]
  /* existing_az_count = length(local.azs) */
  existing_az_count = length(data.aws_availability_zones.available.names)

  # We add bits to the overall bits base
  bitsbase = split("/", var.cidr)[1]
  cidrmask = 23

  # https://github.com/cloudposse/terraform-aws-dynamic-subnets#subnet-calculation-logic
  # https://www.terraform.io/language/functions/range
  cidr_count  = local.existing_az_count * local.existing_az_count
  subnet_bits = local.cidrmask - local.bitsbase


  # I hope you like math!!!
  /*
  cidrsubnet - https://www.terraform.io/docs/language/functions/cidrsubnet.html
  Param 1 - The overarching CIDR block for the VPC
  Param 2 - The bits of the subnet, by default is 32-local.bits so 8 would be 32-8 = 24 for a /24
  Param 3 - The third Octect
  */
  #Start at index 0, end at 3 which is exclusive
  private_subnet_cidrs = [for netnumber in range(0, local.existing_az_count) : cidrsubnet(var.cidr, local.subnet_bits, netnumber)]

  #Start at Index 3 which is inclusive, end at 6 which is exclusive
  public_subnet_cidrs = [for netnumber in range(local.existing_az_count, local.existing_az_count * 2) : cidrsubnet(var.cidr, local.subnet_bits, netnumber)]

  #Start at Index 6 which is inclusive, end at 9 which is exclusive
  database_subnet_cidrs = [for netnumber in range(local.existing_az_count * 2, local.existing_az_count * 3) : cidrsubnet(var.cidr, local.subnet_bits, netnumber)]
}

#Get static NAT EIPs - In this example only a single static EIP
resource "aws_eip" "nat_gw" {
  vpc = true
  tags = {
    Purpose = "NAT GW EIP"
  }
}

#Build out VPC
module "vpc_active" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
  name    = "${var.name_prefix}-vpc"
  cidr    = var.cidr

  # Specify the AZs the VPC will exist in
  azs = local.azs

  private_subnets  = local.private_subnet_cidrs
  database_subnets = local.database_subnet_cidrs
  public_subnets   = local.public_subnet_cidrs

  create_database_subnet_group = true #Needs to be made before any RDS to eliminate count cannot be computed error.

  # No internet for the DB subnet(s)
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false
  create_database_nat_gateway_route      = false

  manage_default_route_table = true
  default_route_table_tags = {
    DefaultRouteTable = true
  }

  enable_dns_hostnames = true # Should be true to enable DNS hostnames in the VPC
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  external_nat_ip_ids = [aws_eip.nat_gw.id]

  enable_vpn_gateway = false #Required on prem connectivity

  # Default SG in the VPC to egress only
  manage_default_security_group = true
  default_security_group_egress = [
    {
      cidr_blocks = "0.0.0.0/0",
      from_port   = 0,
      to_port     = 0,
      description = "Allow all outbound traffic.",
      protocol    = "-1"
    }
  ]
  default_security_group_ingress = []

  public_subnet_tags = {
    "subnet_type" = "pub"
  }
  private_subnet_tags = {
    "subnet_type" = "pvt"
  }
  database_subnet_tags = {
    "subnet_type" = "db"
  }

  # VPC Flow Logs
  enable_flow_log                                 = true
  create_flow_log_cloudwatch_iam_role             = true
  flow_log_destination_type                       = "cloud-watch-logs"
  flow_log_file_format                            = "plain-text"
  flow_log_traffic_type                           = "ALL"
  flow_log_cloudwatch_log_group_retention_in_days = var.cloud_watch_retention
  flow_log_destination_arn                        = aws_cloudwatch_log_group.vpc_flow_logs.arn
}