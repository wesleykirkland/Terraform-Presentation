variable "image_id" {
    description = "AMI Id"
  type = string
}

variable "availability_zone_names" {
    description = "AZ ids"
    type    = list(string)
  default = ["us-west-1a"]
}

variable "docker_ports" {
    description = "Docker Port Mapping"
  type = list(object({
    internal = number
    external = number
    protocol = string
  }))
  default = [
    {
      internal = 8300
      external = 8300
      protocol = "tcp"
    }
  ]
}