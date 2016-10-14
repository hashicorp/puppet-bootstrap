# -*- mode: ruby -*-
# vi: set ft=ruby :

# PLUGINS = %w(vagrant-librarian-puppet vagrant-puppet-install vagrant-vbguest)
PLUGINS = %w().freeze

plugins_installed = false
PLUGINS.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    system("vagrant plugin install #{plugin}") && plugins_installed = true
  end
end
raise('plugins installed. Run command again.') if plugins_installed

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
  # You can search for boxes at https://atlas.hashicorp.com/search.

  config.vm.hostname = 'bootstrap'

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network 'private_network', :type => 'dhcp'

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network 'public_network'

  config.vm.define 'ubuntu-14.04', :primary => true do |ubuntu|
    ubuntu.vm.box = 'puppetlabs/ubuntu-14.04-64-nocm'
    provider_settings(ubuntu, 'ubuntu-14.04')
    install_puppet(ubuntu)
  end

  config.vm.define 'ubuntu-16.04', :autostart => false do |ubuntu|
    ubuntu.vm.box = 'puppetlabs/ubuntu-16.04-64-nocm'
    provider_settings(ubuntu, 'ubuntu-16.04')
    install_puppet(ubuntu)
  end

  config.vm.define 'centos-5.11', :autostart => false do |centos|
    centos.vm.box = 'puppetlabs/centos-5.11-64-nocm'
    provider_settings(centos, 'centos-5.11')
    install_puppet(centos)
  end

  config.vm.define 'centos-6.6', :autostart => false do |centos|
    centos.vm.box = 'puppetlabs/centos-6.6-64-nocm'
    provider_settings(centos, 'centos-6.6')
    install_puppet(centos)
  end

  config.vm.define 'centos-7.2', :autostart => false do |centos|
    centos.vm.box = 'puppetlabs/centos-7.2-64-nocm'
    provider_settings(centos, 'centos-7.2')
    install_puppet(centos)
  end

  config.vm.define 'osx', :autostart => false do |osx|
    osx.vm.box = 'jhcook/osx-elcapitan-10.11'
    provider_settings(osx, 'osx-10.11', true)
    install_puppet(osx)
  end

  config.vm.define 'windows', :autostart => false do |windows|
    windows.vm.box = 'opentable/win-2012r2-standard-amd64-nocm'
    provider_settings(windows, 'win-2012r2-standard', true)
    install_puppet(windows, 'windows')
  end

  # Extract common settings, whilst allowing some differences
  def provider_settings(os, name, gui = false)
    # Provider-specific configuration for VirtualBox:
    os.vm.provider 'virtualbox' do |vb|
      vb.name = "bootstrap-#{name}"
      vb.gui = gui
      vb.memory = 2048
      vb.cpus = 2
      vb.customize ['modifyvm', :id, '--ioapic', 'on']
    end
    # Add other supported providers...
  end

  def install_puppet(os, kernel = 'unix')
    # Provision with Shell to install puppet and prep for puppet dependencies
    case kernel.to_s
    when 'unix'
      os.vm.provision 'shell', :inline => <<-SHELL
        curl -sSL https://git.io/vLD6L | sudo bash -s '' locdev pc1
      SHELL
    when 'windows'
      os.vm.provision 'shell', :inline => <<-SHELL
        $env:PuppetCollection = 'pc1'
        $env:PuppetEnvironment = 'locdev'
        iex ((New-Object System.Net.WebClient).DownloadString('https://git.io/vanax'))
      SHELL
    else
      raise("Don't know how to install puppet on #{kernel}")
    end
  end
end
