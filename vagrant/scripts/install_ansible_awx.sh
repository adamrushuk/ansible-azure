#!/bin/bash

# Installs Ansible AWX
echo "INFO: Started Installing Ansible AWX..."

# Install prereq: Docker SDK for Python
echo "INFO: Started Installing Docker SDK for Python..."
pip install docker
echo "INFO: Finished Installing Docker SDK for Python."

# Clone AWX repo
ansible_git_folder="/root/awx/"
if [ ! -d "$ansible_git_folder" ]
then
    echo "INFO: Cloning Ansible AWX repo..."
    cd /root/
    git clone https://github.com/ansible/awx.git
else
    echo "INFO: Ansible AWX repo already exists...SKIPPING."
fi

# Copy (overwrite) inventory file from vagrant share
echo "INFO: Copying Ansible AWX Inventory file..."
\cp /vagrant/vagrant/scripts/awx_inventory.ini /root/awx/installer/inventory

# Run installer Playbook
echo "INFO: Running Ansible AWX install playbook..."
cd /root/awx/installer/
ansible-playbook -i inventory install.yml

# Install Ansible Tower CLI
pip install ansible-tower-cli

echo "INFO: Finished Installing Ansible AWX. View containers with 'docker ps'
INFO: Confirm AWX migration tasks have completed by running 'docker logs -f awx_task'
INFO: Look for these Final migration log messages:
    Default organization added
    Demo Credential, Inventory, and Job Template added
    Successfully registered instance awx
    Creating instance group tower"
