Vagrant.configure("2") do |config|
  
  config.vm.define "bullseye" do |bullseye|
    bullseye.vm.box = "debian/bullseye64"
    bullseye.vm.hostname = "zabbix-debian"
    bullseye.vm.network "private_network", ip: "10.10.10.10", virtualbox__intnet: "vboxnet0"
    bullseye.vm.network "forwarded_port", guest: 80, host: 8001, host_ip: "127.0.0.1"
    bullseye.vm.network "forwarded_port", guest: 8080, host: 8081, host_ip: "127.0.0.1"

    bullseye.vm.provision "file", source: "zbx60_bullseye_pgtdb_nginx.sh", destination: "/tmp/install_zabbix.sh"

    bullseye.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install -y curl
    bash /tmp/install_zabbix.sh
    SHELL
  end

  config.vm.define "rhl" do |rhl|
    rhl.vm.box = "almalinux/8"
    rhl.vm.hostname = "zabbix-rhl"
    rhl.vm.network "private_network", ip: "10.10.10.10", virtualbox__intnet: "vboxnet0"
    rhl.vm.network "forwarded_port", guest: 80, host: 8002, host_ip: "127.0.0.1"
    rhl.vm.network "forwarded_port", guest: 8080, host: 8082, host_ip: "127.0.0.1"
    
    rhl.vm.provision "file", source: "zbx60_rh8_pgtdb_nginx.sh", destination: "/tmp/install_zabbix.sh"

    rhl.vm.provision "shell", inline: <<-SHELL
    bash /tmp/install_zabbix.sh
    SHELL
  end

  config.vm.define "jammy" do |jammy|
    jammy.vm.box = "ubuntu/jammy64"
    jammy.vm.hostname = "zabbix-jammy"
    jammy.vm.network "private_network", ip: "10.10.10.10", virtualbox__intnet: "vboxnet0"
    jammy.vm.network "forwarded_port", guest: 80, host: 8003, host_ip: "127.0.0.1"
    jammy.vm.network "forwarded_port", guest: 8080, host: 8083, host_ip: "127.0.0.1"
    
    jammy.vm.provision "file", source: "zbx60_jammy_pgtdb_nginx.sh", destination: "/tmp/install_zabbix.sh"

    jammy.vm.provision "shell", inline: <<-SHELL
    bash /tmp/install_zabbix.sh
    SHELL
  end

end
