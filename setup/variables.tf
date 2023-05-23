# AWS Specifications
variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "availability_zone" {
  type    = string
  default = "ap-southeast-1a"
}

variable "key_pair_name" {
  type    = string
  default = "Terraform"
}

variable "experimental_public_cidr" {
  description = "Public CIDR Block"
  type        = string
  default     = "111.0.10.0/24"
}

variable "experimental_internal_cidr" {
  description = "Public CIDR Block"
  type        = string
  default     = "192.168.1.0/24"
}

variable "ubuntu_web_server_ip" {
  type    = string
  default = "192.168.1.200"
}

variable "siem_ip" {
  type    = string
  default = "192.168.1.100"
}

variable "DC_ip" {
  type    = string
  default = "192.168.1.150"
}

variable "windows_host_ip" {
  type    = string
  default = "192.168.1.151"
}

variable "router_internal_ip" {
  type    = string
  default = "192.168.1.5"
}

variable "router_external_ip" {
  type    = string
  default = "111.0.10.5"
}

variable "attacker_ip" {
  type    = string
  default = "111.0.10.10"
}

# Deployment Configuration

## Splunk or ELK or vanilla deployment 
## Currently, only one of either Splunk or ELK can be deployed
variable "is_splunk" {
  type    = bool
  default = true
}

variable "is_elk" {
  type    = bool
  default = false
}

