# Plugin checker by DevNIX: https://github.com/DevNIX/Vagrant-dependency-manager
# vagrant-reload is required to reboot Windows machines and retain Vagrant connection
require File.dirname(__FILE__)+'./Vagrant/Plugin/dependency_manager'
check_plugins ['vagrant-reload']

# Variables
## Boxes
linux_box_name      = 'bento/centos-7.6'
linux_box_version   = '201812.27.0'

## Network
## NIC Adapter #2 (1st NIC is reserved for Vagrant comms)
net_prefix          = '192.168.10'
ansible01_ip        = "#{net_prefix}.20"

# Main configuration
Vagrant.configure('2') do |config|

  # VirtualBox global box settings
  config.vm.provider 'virtualbox' do |vb|
    vb.linked_clone = true
    vb.gui          = true
    vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
    vb.customize ['setextradata', 'global', 'GUI/SuppressMessages', 'all']
  end

  # Increase timeout in case VMs joining the domain take a while to boot
  config.vm.boot_timeout = 1200

  # Ansible Control VM
  config.vm.define 'ansible01' do |subconfig|
    # CPU and RAM
    subconfig.vm.provider 'virtualbox' do |vb|
      vb.cpus   = '2'
      vb.memory = '4096'
    end

    # Hostname and networking
    subconfig.vm.hostname    = 'ansible01'
    subconfig.vm.box         = linux_box_name
    subconfig.vm.box_version = linux_box_version
    subconfig.vm.network 'private_network', ip: ansible01_ip
    subconfig.vm.network 'forwarded_port', guest: 22, host: 33520, auto_correct: true
    subconfig.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__auto: true

    # Provisioning
    subconfig.vm.provision 'shell', path: 'vagrant/scripts/install_common.sh'
    # Install Ansible
    subconfig.vm.provision 'shell', path: 'vagrant/scripts/install_ansible_azure.sh'
    # Install Docker
    subconfig.vm.provision 'shell', path: 'vagrant/scripts/install_docker_ce.sh'
    # Install Ansible AWX
    subconfig.vm.provision 'shell', path: 'vagrant/scripts/install_ansible_awx.sh'
  end

end
