
# OpenStack authentication
variable "openstack_cloud" {
  type        = string
  description = "Nom du cloud OpenStack défini dans clouds.yaml"
}

variable "OS_PROJECT_NAME" {
  type        = string
  description = "Nom du projet OpenStack"
}

variable "OS_USERNAME" {
  type = string
}

variable "OS_PASSWORD" {
  type      = string
  sensitive = true
}

variable "OS_PROJECT_ID" {
  type = string
}

variable "OS_AUTH_URL" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

# VM configuration
variable "vm_flavor" {
  type = string
}

variable "vm_image" {
  type = string
}

variable "floating_ip_pool" {
  type = string
}
variable "network_name" {
  type        = string
  description = "Nom du réseau privé"
}
# Réseau
variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

# IP privée spécifique
variable "machine_db_private_ip" {
  type = string
}

# Sécurité
variable "admin_cidr" {
  type = string
}

variable "app_private_cidr" {
  type = string
}

# Clés publiques SSH
variable "sysadmin_pub_key" {
  type = string
}

variable "devops_aya_pub_key" {
  type = string
}

variable "houssam_pub_key" {
  type = string
}
# Mots de passe PostgreSQL (sensibles)
variable "dbadmin_password" {
  type      = string
  sensitive = true
}

variable "houssam_password" {
  type      = string
  sensitive = true
}
