variable "credit_card" {
  description = "Your Credit Card Info"
  sensitive   = true
  type        = object({
      number = number
      cvv    = number
      date   = string
      zip    = number
    })
}

variable "my_info" {
    description = "My information for Dominos to contact me"
    type = object({
        first_name    = string
        last_name     = string
        email_address = string
        phone_number  = string
    })
}

variable "my_address" {
  description = "My address to locate the closest store"
  type = map(string)
}