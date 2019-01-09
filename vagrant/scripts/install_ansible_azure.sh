#!/bin/bash

# Install Ansible
echo "INFO: Started Installing Ansible for Azure..."

# Install pre-requisite packages
sudo yum check-update; sudo yum install -y gcc libffi-devel python-devel openssl-devel epel-release
sudo yum install -y python-pip python-wheel

# Install Ansible and Azure SDKs via pip
sudo pip install ansible[azure]

# Add support for Windows via WinRM
sudo pip install pywinrm
echo "INFO: Finished Installing Ansible for Azure."
