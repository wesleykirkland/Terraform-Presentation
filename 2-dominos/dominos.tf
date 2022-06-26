#Find the closest store to us
data "dominos_address" "addr" {
  street = var.my_address.street
  city   = var.my_address.city
  state  = var.my_address.state
  zip    = var.my_address.zip
# [for key in keys(var.delivery_address) : var.delivery_address[key]]
}

#Dynamically find our store id
data "dominos_store" "store" {
  address_url_object = "${data.dominos_address.addr.url_object}"
}

data "dominos_menu_item" "item" {
  store_id     = "${data.dominos_store.store.store_id}"
  query_string = ["bbq", "chicken", "large"]
}

resource "dominos_order" "order" {
  address_api_object = "${data.dominos_address.addr.api_object}"
  item_codes         = ["${data.dominos_menu_item.item.matches.0.code}"]
  store_id           = "${data.dominos_store.store.store_id}"
}   