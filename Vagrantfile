# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "common-provision.sh"

  # Kubernetes Master Server
  config.vm.define "k8s-master" do |kmaster|
    kmaster.vm.box = "generic/debian12"
    kmaster.vm.hostname = "k8s-master.localdomain"
    kmaster.vm.network "public_network", ip: "10.0.0.130", :netmask => "255.255.255.0", :bridge => "eno1"
    kmaster.vm.provider "virtualbox" do |v|
      v.name = "k8s-master"
      v.memory = 2048
      v.cpus = 2
    end
    kmaster.vm.provision "shell", path: "bootstrap_kmaster.sh"
  end

  NodeCount = 2
  # Kubernetes Worker Nodes
  (1..NodeCount).each do |i|
    config.vm.define "k8s-wrk#{i}" do |workernode|
      workernode.vm.box = "generic/debian12"
      workernode.vm.hostname = "k8s-wrk#{i}.localdomain"
      workernode.vm.network "public_network", ip: "10.0.0.13#{i}", :netmask => "255.255.255.0", :bridge => "eno1"
      workernode.vm.provider "virtualbox" do |v|
        v.name = "k8s-wrk#{i}"
        v.memory = 1024
        v.cpus = 1
      end
      workernode.vm.provision "shell", path: "bootstrap_kworker.sh"
    end
  end
end

