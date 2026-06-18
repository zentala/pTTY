# Oracle Cloud Infrastructure Terraform configuration for tmux-persistent-console testing
# Free Tier: 4 ARM cores, 24GB RAM, 200GB storage

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Provider configuration
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Variables
variable "tenancy_ocid" {
  description = "The OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "The OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the public key"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file"
  type        = string
}

variable "region" {
  description = "The OCI region"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "The OCID of the compartment"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "instance_name" {
  description = "Name for the test instance"
  type        = string
  default     = "tmux-console-test"
}

# Data sources
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Get Ubuntu 24.04 ARM image
data "oci_core_images" "ubuntu_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Get the default VCN
data "oci_core_vcns" "vcns" {
  compartment_id = var.compartment_ocid
  filter {
    name   = "display_name"
    values = ["*"]
  }
}

# Get the default subnet
data "oci_core_subnets" "subnets" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_vcns.vcns.virtual_networks[0].id
}

# Security Group
resource "oci_core_network_security_group" "tmux_console_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_vcns.vcns.virtual_networks[0].id
  display_name   = "tmux-console-test-nsg"
}

# SSH access rule
resource "oci_core_network_security_group_security_rule" "ssh_ingress" {
  network_security_group_id = oci_core_network_security_group.tmux_console_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

# HTTP access rule (for potential web testing)
resource "oci_core_network_security_group_security_rule" "http_ingress" {
  network_security_group_id = oci_core_network_security_group.tmux_console_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 8080
      max = 8090
    }
  }
}

# Egress rule (allow all outbound)
resource "oci_core_network_security_group_security_rule" "egress_all" {
  network_security_group_id = oci_core_network_security_group.tmux_console_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
}

# Cloud-init script for tmux-persistent-console setup
locals {
  cloud_init = base64encode(templatefile("${path.module}/../configs/cloud-init.yaml", {
    ssh_public_key = file(var.ssh_public_key_path)
  }))
}

# ARM Instance (Free Tier: up to 4 OCPUs, 24GB RAM)
resource "oci_core_instance" "tmux_console_test" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_name
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2  # Use 2 out of 4 free cores
    memory_in_gbs = 12 # Use 12 out of 24 free GB
  }

  create_vnic_details {
    subnet_id                 = data.oci_core_subnets.subnets.subnets[0].id
    display_name              = "${var.instance_name}-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = replace(var.instance_name, "_", "-")
    nsg_ids                   = [oci_core_network_security_group.tmux_console_nsg.id]
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_images.images[0].id
    boot_volume_size_in_gbs = 50 # Use 50GB out of 200GB free
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = local.cloud_init
  }

  timeouts {
    create = "60m"
  }

  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
    ]
  }
}

# Outputs
output "instance_public_ip" {
  description = "Public IP of the test instance"
  value       = oci_core_instance.tmux_console_test.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the test instance"
  value       = oci_core_instance.tmux_console_test.private_ip
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh ubuntu@${oci_core_instance.tmux_console_test.public_ip}"
}

output "instance_ocid" {
  description = "OCID of the created instance"
  value       = oci_core_instance.tmux_console_test.id
}
