#/bin/bash

apt-get update   
apt-get install apt-transport-https ca-certificates   
mkdir /etc/apt/keyrings/   
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update 
apt install kubelet kubeadm kubectl containerd
apt-mark hold kubelet kubeadm kubectl
