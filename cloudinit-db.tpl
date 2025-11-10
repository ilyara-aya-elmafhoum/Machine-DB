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

  - name: nouhaila
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${nouhaila_public_key}

package_update: true
package_upgrade: true
packages:
  - git
  - curl
  - wget
  - unzip
  - ufw

runcmd:
  # 1 Ajouter le dépôt officiel PostgreSQL
  - curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
  - echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
  - apt-get update

  # 2 Installer PostgreSQL 16.8
  - apt-get install -y postgresql-16=16.8* postgresql-client-16=16.8* postgresql-contrib-16=16.8*

  # 3 Activer et démarrer PostgreSQL
  - systemctl enable postgresql
  - systemctl start postgresql

  # 4 Création des rôles PostgreSQL avec mots de passe dynamiques
  - sudo -u postgres psql -c "CREATE ROLE dbadmin WITH LOGIN PASSWORD '${dbadmin_password}';"
  - sudo -u postgres psql -c "CREATE ROLE houssam WITH LOGIN PASSWORD '${houssam_password}';"

  # 5 Création de la base de données wesports et assignation des droits
  - sudo -u postgres psql -c "CREATE DATABASE wesports OWNER dbadmin;"
  - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE wesports TO houssam;"

  # 6 Configuration du firewall
  - ufw allow 22
  - ufw allow 5432
  - ufw --force enable
