terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "openstack" {
  user_name        = var.OS_USERNAME
  password         = var.OS_PASSWORD
  auth_url         = var.OS_AUTH_URL
  tenant_id        = var.OS_PROJECT_ID
  user_domain_name = "Default"
  region           = "dc3-a"
}

# Security Group
resource "openstack_networking_secgroup_v2" "db_sg" {
  name        = "machine-db-sg"
  description = "Sécurité pour machine DB"
}


resource "openstack_networking_secgroup_rule_v2" "allow_ssh_db" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.admin_cidr
  security_group_id = openstack_networking_secgroup_v2.db_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "allow_postgres" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_ip_prefix  = var.app_private_cidr  # pour limiter l’accès au backend seulement
  security_group_id = openstack_networking_secgroup_v2.db_sg.id
}

# Cloud-init for DB
data "template_file" "cloudinit_db" {
  template = file("${path.module}/cloudinit-db.tpl")
  vars = {
    sys_admin_public_key   = var.sysadmin_pub_key
    devops_aya_public_key = var.devops_aya_pub_key
    houssam_public_key    = var.houssam_pub_key
    dbadmin_password     = var.dbadmin_password
    houssam_password     = var.houssam_password
  }
}

# Private Port for Database
resource "openstack_networking_port_v2" "db_port" {
  name       = "db-port"
  network_id = var.network_id

  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = var.machine_db_private_ip
  }
}

# Compute Instance for Database
resource "openstack_compute_instance_v2" "machine_db" {
  name        = "machine-DB"
  image_name  = var.vm_image
  flavor_name = var.vm_flavor
  key_pair    = var.ssh_key_name

  network {
    port = openstack_networking_port_v2.db_port.id
  }

  security_groups = [openstack_networking_secgroup_v2.db_sg.name]
  user_data       = data.template_file.cloudinit_db.rendered
}

# Floating IP 
resource "openstack_networking_floatingip_v2" "db_fip" {
  pool    = var.floating_ip_pool
  port_id = openstack_networking_port_v2.db_port.id
}

# OUTPUT
output "db_ip" {
  value = openstack_networking_floatingip_v2.db_fip.address
}
