provider "dominos" {
  first_name    = var.my_info.first_name
  last_name     = var.my_info.last_name
  email_address = var.my_info.email_address
  phone_number  = var.my_info.phone_number

  credit_card {
    number = var.credit_card.number
    cvv    = var.credit_card.cvv
    date   = var.credit_card.date
    zip = var.credit_card.zip
  }
}