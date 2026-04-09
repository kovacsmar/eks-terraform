variable "tls_cert_path" {
  default = "../../secrets/fullchain.pem"
  type    = string
}

variable "tls_key_path" {
  default = "../../secrets/privkey.pem"
  type    = string
}
