#!/bin/bash

# Vars
awx_host_url="http://192.168.10.20"
awx_username="admin"
awx_password="password"
awx_projects_source_folder="/vagrant/ansible-projects/"
awx_projects_dest_folder="/var/lib/awx/projects"
azure_credential_file_path="/vagrant/azure_ansible_credentials.yml"
ssh_public_key_path="$HOME/.ssh/id_rsa.pub"
awx_http_port_check=80
awx_demo_data_import_check="tower-cli instance_group get tower 2> /dev/null"

# Create SSH key
if [ ! -f "$ssh_public_key_path" ]
then
    echo -e "\nINFO: Started Creating new SSH key..."
    echo -e "\n\n\n" |  ssh-keygen -t rsa -C "dev@adamrushuk.github.io" -N ""
else
    echo -e "\nINFO: SSH key already exists...SKIPPING."
fi
ssh_public_key=`cat "$ssh_public_key_path"`

# Configure Ansible AWX using Tower CLI
echo -e "\nINFO: Started Configuring Ansible AWX using Tower CLI..."

# Configure host - include "http:" as it default to HTTPS
tower-cli config host $awx_host_url

# Disable SSL verification to allow insecure HTTP traffic
tower-cli config verify_ssl false

# Configure login
tower-cli config username $awx_username
tower-cli config password $awx_password

# Wait for AWX Web Server to be online
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:$awx_http_port_check)" -ne "200" ]]; do
    echo "INFO: AWX Web Server NOT online yet...waiting 30 seconds"
    sleep 30
done
echo "INFO: AWX Web Server now online...READY"

# Wait for AWX Demo Data import to finish
eval $awx_demo_data_import_check
while [[ $? -ne 0 ]]; do
    echo "INFO: AWX Data Import not complete yet...waiting 5 seconds"
    sleep 5
    eval $awx_demo_data_import_check
done
echo "INFO: AWX Data Import now complete"

# Copy projects folder
if [ -d "$awx_projects_source_folder" ]
then
    echo -e "\nINFO: Copying Ansible Projects folder(s) for AWX..."
    rsync -avz "$awx_projects_source_folder"* $awx_projects_dest_folder
else
    echo -e "\nINFO: Ansible Projects source folder missing...SKIPPING."
fi

# Create project
echo -e "\nINFO: Creating Azure Project in AWX..."
tower-cli project create --name "Azure Project" --description "Azure Playbooks" --scm-type "manual" --local-path "azure-linux-vm" --organization "Default"

# Create Azure inventory
echo -e "\nINFO: Creating Azure Inventory in AWX..."
tower-cli inventory create --name "Azure Inventory" --description "Azure Inventory" --organization "Default" --variables "ssh_public_key: \"$ssh_public_key\""

# Create Azure credential
echo -e "\nINFO: Creating Azure Credential in AWX..."
tower-cli credential create --name "Azure Credential" --description "Azure Credential" --organization "Default" --credential-type "Microsoft Azure Resource Manager" --inputs "@$azure_credential_file_path"

# Create Azure job template for a simple Resource Group
echo -e "\nINFO: Creating job template for a simple Azure Resource Group..."
# WORKAROUND: you must supply an SSH credential type initially
tower-cli job_template create --name "Azure Resource Group" --description "Azure Resource Group - Job Template" --inventory "Azure Inventory" --project "Azure Project" --playbook "resource_group.yml" --credential "Demo Credential"
# WORKAROUND: you can then associate an Azure credential afterwards
tower-cli job_template associate_credential --job-template "Azure Resource Group" --credential "Azure Credential"

# Create Azure job template for a CentOS Linux VM and all required resources
echo -e "\nINFO: Creating job template for a CentOS Linux VM and all required resources in Azure..."
# WORKAROUND: you must supply an SSH credential type initially
tower-cli job_template create --name "Azure CentOS Linux VM" --description "Azure CentOS Linux VM - Job Template" --inventory "Azure Inventory" --project "Azure Project" --playbook "centos_vm.yml" --credential "Demo Credential"
# WORKAROUND: you can then associate an Azure credential afterwards
tower-cli job_template associate_credential --job-template "Azure CentOS Linux VM" --credential "Azure Credential"
