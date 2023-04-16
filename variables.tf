variable "key_pair_name" {
  description = "Name for the SSH key pair"
  type        = string
}
variable "cidr_block_public" {
  description = "10.10.1.0/24"
  type        = string
}
variable "availability_zone_public" {
  description = "us-east-1a Availability zone"
  type        = string
}
