#!/bin/bash
# common setup and packeges intallation for all the instances

echo "Updating apt repositories"
sudo apt update
echo "Applying a full OS upgrade"
sudo apt dist-upgrade
sudo apt install curl gpg -y

# setting timeson to America/Chicago
echo "Setting up Time Zone"
sudo timedatectl set-timezone America/Chicago

# disble swap
echo "Disabling Swap Space"
sudo swapoff -a
# comment swap partition line in fstab file
echo "Removing Swap from fstab"
sudo sed -i 's/^UUID.*swap/#&/' /etc/fstab

# uncomment ipv4-forwarding for linux kernel
echo "Enabling Kernel parameters"
#sudo sed -i '/net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# apply kernel parameters changed
echo "Applying Kernel parameters"
sudo sysctl --system

# setting hostname
echo "Setting up /etc/hosts file"
sudo echo "10.0.0.130 k8s-master.localdomain k8s-master" >> /etc/hosts
sudo echo "10.0.0.131 k8s-wrk1.localdomain k8s-wrk1" >> /etc/hosts
sudo echo "10.0.0.132 k8s-wrk2.localdomain k8s-wrk2" >> /etc/hosts

echo "Enabling bridge netfilter kernel module"
# enabling bridge netfilter & overlay kernel module
cat << EOF | sudo tee /etc/modules-load.d/k8s-modules.conf
br_netfilter
overlay
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo "Installing containerd"
sudo apt install containerd syslog-ng -y
sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.bak

echo "Dumping default containerd config"
containerd config default | sudo tee /etc/containerd/config.toml
echo "Setting up Cgroup in containerd config"
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo ln -s /opt/cni/bin /usr/lib/cni

echo "Restarting & Enabling containerd"
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "Setting up kubernetes(1.29) respositories and GPG key"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Updating apt sources and installing kubernetes tools"
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

