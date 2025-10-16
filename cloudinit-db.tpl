#cloud-config
ssh_pwauth: false
disable_root: true

users:
  - name: sysadmin
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${sys_admin_public_key}

  - name: devops-aya
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${devops_aya_public_key}

  - name: houssam
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${houssam_public_key}

package_update: true
package_upgrade: true
packages:
  - postgresql
  - postgresql-contrib
  - git
  - curl
  - wget
  - unzip
  - ufw

runcmd:
  # Activer et démarrer PostgreSQL
  - systemctl enable postgresql
  - systemctl start postgresql

  # Création des rôles PostgreSQL avec mots de passe dynamiques
  - sudo -u postgres psql -c "CREATE ROLE dbadmin WITH LOGIN PASSWORD '${dbadmin_password}';"
  - sudo -u postgres psql -c "CREATE ROLE houssam WITH LOGIN PASSWORD '${houssam_password}';"

  # Création de la base de données wesports et assignation des droits
  - sudo -u postgres psql -c "CREATE DATABASE wesports OWNER dbadmin;"
  - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE wesports TO houssam;"

  # Configuration du firewall
  - ufw allow 22
  - ufw allow 5432
  - ufw --force enable
