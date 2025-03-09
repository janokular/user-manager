Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  
  config.vm.define "debian" do |debian|
    debian.vm.hostname = "debian"
    debian.vm.network "private_network", ip: "10.23.45.20"
    
    debian.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y geoip-bin
    SHELL
  end
end