variable "region" {
  description = "AWS Region to deploy to"
  type        = string
}

variable "name_prefix" {
  description = "Name Prefix for everything in the env"
  type        = string
}

variable "region_azs" {
  description = "AZs to deploy in, AZ letter only"
  type        = list(string)
}

variable "cidr" {
  description = "CIDR Block to deploy"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cloud_watch_retention" {
  description = "CloudWatch Retention"
  type        = number
  default     = 7
}