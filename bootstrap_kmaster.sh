#!/bin/bash

echo "[TASK 1] Initialize Kubernetes Cluster"
sudo kubeadm init --control-plane-endpoint=10.0.0.130 --apiserver-advertise-address=10.0.0.130 --pod-network-cidr=192.168.0.0/16 --upload-certs >> /home/vagrant/kubeinit.log 2>/dev/null
chown -R vagrant:vagrant /home/vagrant/kubeinit.log

echo "[TASK 2] Copy kube admin config to Vagrant user .kube directory"
mkdir /home/vagrant/.kube
sudo cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube/config

echo "[TASK 3] Deploy Calico network"
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml

echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /home/vagrant/join-cluster.sh
chown vagrant:vagrant /home/vagrant/join-cluster.sh

echo "[TASK 5] Ensure vagrant user and password match for ssh"
echo "vagrant:vagrant" | sudo chpasswd

echo "[TASK 6] Enabling Password Authentication and reloading service"
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl force-reload sshd

