#!/bin/bash

# Join worker nodes to the Kubernetes cluster
echo "[TASK 1] Join node to Kubernetes Cluster"
sudo apt install -q -y sshpass >/dev/null 2>&1
echo "[TASK 2] Create dir where kube config reside"
mkdir -p /home/vagrant/.kube
chown vagrant:vagrant /home/vagrant/.kube/
echo "[TASK 3] Copy config file from master no worker"
sudo sshpass -p vagrant scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no k8s-master.localdomain:/home/vagrant/.kube/config /home/vagrant/.kube/config 2>/dev/null
echo "[TASK 4] Copy join script from master to worker"
sudo sshpass -p vagrant scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no k8s-master.localdomain:/home/vagrant/join-cluster.sh /home/vagrant/join-cluster.sh 2>/dev/null
echo "[TASK 4] Execute join kubernets cluster script"
bash /home/vagrant/join-cluster.sh >/dev/null 2>&1

