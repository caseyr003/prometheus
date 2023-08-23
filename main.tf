# Provision compartment for all resources
resource "oci_identity_compartment" "prometheus_project" {
  compartment_id = var.tenancy_ocid
  description    = "Compartment for resources used for setting up Prometheus using Terraform and Ansible."
  name           = "prometheus_project"
}

##################
### NETWORKING ###
##################

# Provision virtual cloud network
resource "oci_core_virtual_network" "prometheus_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.prometheus_project.id
  display_name   = "prometheus_vcn"
}

# Provision internet gateway
resource "oci_core_internet_gateway" "prometheus_ig" {
  compartment_id = oci_identity_compartment.prometheus_project.id
  display_name   = "prometheus_ig"
  vcn_id         = oci_core_virtual_network.prometheus_vcn.id
}

# Provision route table to allow internet access to subnet
resource "oci_core_route_table" "prometheus_rt" {
  compartment_id = oci_identity_compartment.prometheus_project.id
  vcn_id         = oci_core_virtual_network.prometheus_vcn.id
  display_name   = "prometheus_rt"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.prometheus_ig.id
  }
}

# Provision security list to allow ssh and prometheus dashboard access
resource "oci_core_security_list" "prometheus_sl" {
  compartment_id = oci_identity_compartment.prometheus_project.id
  display_name   = "prometheus_sl"
  vcn_id         = oci_core_virtual_network.prometheus_vcn.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = 9090
      min = 9090
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "10.0.2.0/24"
    tcp_options {
      max = 9100
      min = 9100
    }
  }
}

# Lookup availability domain 2 in ashburn region
data "oci_identity_availability_domain" "ad2" {
  compartment_id = var.tenancy_ocid
  ad_number      = 2
}

# Provision subnet in availability domain 2
resource "oci_core_subnet" "subnet_ad2" {
  availability_domain = data.oci_identity_availability_domain.ad2.name
  cidr_block          = "10.0.2.0/24"
  display_name        = "subnet_ad2"
  compartment_id      = oci_identity_compartment.prometheus_project.id
  vcn_id              = oci_core_virtual_network.prometheus_vcn.id
  dhcp_options_id     = oci_core_virtual_network.prometheus_vcn.default_dhcp_options_id
  route_table_id      = oci_core_route_table.prometheus_rt.id
  security_list_ids   = [oci_core_security_list.prometheus_sl.id]
}

###############
### COMPUTE ###
###############

# Provision server that will run prometheus dashboard
resource "oci_core_instance" "observer" {
  availability_domain = data.oci_identity_availability_domain.ad2.name
  compartment_id      = oci_identity_compartment.prometheus_project.id
  display_name        = "observer"
  shape               = var.shape
  freeform_tags       = { "type" = "observer" }

  source_details {
    source_id   = var.image_ocid
    source_type = "image"
  }

  create_vnic_details {
    subnet_id  = oci_core_subnet.subnet_ad2.id
    private_ip = "10.0.2.100"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# Provision server that will run node exporter
resource "oci_core_instance" "target" {
  availability_domain = data.oci_identity_availability_domain.ad2.name
  compartment_id      = oci_identity_compartment.prometheus_project.id
  display_name        = "target"
  shape               = var.shape

  source_details {
    source_id   = var.image_ocid
    source_type = "image"
  }

  create_vnic_details {
    subnet_id  = oci_core_subnet.subnet_ad2.id
    private_ip = "10.0.2.101"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

############################
### SERVER CONFIGURATION ###
############################

# Wait for server to fully boot before running ansible playbook
resource "null_resource" "wait_for_server_access" {
  provisioner "local-exec" {
    command = "sleep 80"
  }

  depends_on = [
    oci_core_instance.observer,
    oci_core_instance.target
  ]
}

# Run ansible playbook to setup servers with prometheus and node exporter
resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.oci.yml prometheus_playbook.yml"
  }

  depends_on = [
    null_resource.wait_for_server_access
  ]
}
