# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"



Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # Using vagrant-cachier improves performance if you do this repeatedly
    if defined? VagrantPlugins::Cachier
      config.cache.auto_detect = true
    end

    config.vm.define :centos64 do |node|
      node.vm.box = 'centos-64-x64-vbox4210-nocm'
      node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box'
      node.vm.provision "shell", path: "linux.sh"
    end

    config.vm.define :centos65 do |node|
      node.vm.box = 'centos-64-x64-vbox4210-nocm'
      node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box'
      node.vm.provision "shell", inline: "yum update -y"
      node.vm.provision "shell", path: "linux.sh"
    end

    config.vm.define :centos59 do |node|
      node.vm.box = 'centos-59-x64-vbox4210-nocm'
      node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-59-x64-vbox4210-nocm.box'
      node.vm.provision "shell", path: "linux.sh"
    end

    config.vm.define :ubuntu1204 do |node|
      node.vm.box = 'ubuntu-server-12042-x64-vbox4210-nocm'
      node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210-nocm.box'
      node.vm.provision "shell", path: "linux.sh"
    end

    config.vm.define :debian7 do |node|
      node.vm.box = 'debian-70rc1-x64-vbox4210-nocm'
      node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/debian-70rc1-x64-vbox4210-nocm.box'
      node.vm.provision "shell", path: "linux.sh"
    end

    config.vm.define :debian6 do |node|
      node.vm.box = 'debian-607-x64-vbox4210-nocm'
      node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/debian-607-x64-vbox4210-nocm.box'
      node.vm.provision "shell", path: "linux.sh"
    end

    config.vm.define :arch do |node|
      node.vm.box = 'arch64'
      node.vm.box_url = 'http://iweb.dl.sourceforge.net/project/flowboard-vagrant-boxes/arch64-2013-07-26-minimal.box'
      node.vm.provision "shell", path: "linux.sh"
    end

end
