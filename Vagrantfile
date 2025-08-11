IMAGE_NAME = "generic/debian12"
CPU = 2
MEMORY = 2048 # MB
NODE = 3


Vagrant.configure("2") do |config|
  (1..NODE).each do |i|
    # config.vm.provision "shell", path: 'script.sh'
    config.vm.define "node-#{i}" do |node|
      node.vm.box = IMAGE_NAME
      node.vm.network "private_network", ip: "192.168.60.20#{i}/24"
      node.vm.provision "shell", run: "always", inline: "sed 's/127\.0\.0\.1.*k8s.*/192\.168\.60\.20#{i} node-#{i}/' -i /etc/hosts"
      node.vm.provision "shell", run: "always", inline: "echo 'set -g mouse' > /home/vagrant/.tmux.conf"
      node.vm.hostname = "node-#{i}"
      config.vm.provider "libvirt" do |libvirt|
        libvirt.cpus = CPU
        libvirt.memory = MEMORY
      end
    end
  end
end
