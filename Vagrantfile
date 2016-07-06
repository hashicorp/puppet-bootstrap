# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = 'opentable/win-2012r2-standard-amd64-nocm'
  config.vm.hostname = 'bootstrap'

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network 'forwarded_port', :host => 33_389, :guest => 3389,
  #                                    :id => 'rdp', :auto_correct => true

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network 'private_network', :type => 'dhcp'

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider 'virtualbox' do |vb|
    vb.name = 'bootstrap-win-2012r2-standard'
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
    vb.memory = 2048
    vb.cpus = 2
    vb.customize ['modifyvm', :id, '--ioapic', 'on']
  end

  # Provision with Shell to install puppet
  config.vm.provision 'shell', :inline => <<-SHELL
    $env:PuppetEnvironment = "vagrant"
    iex ((New-Object net.webclient).DownloadString('https://git.io/vanax'))
  SHELL
end
