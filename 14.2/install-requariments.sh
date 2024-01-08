#/bin/bash

apt-get update -y
apt-get install apt-transport-https ca-certificates -y
mkdir /etc/apt/keyrings/
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -y
apt install kubelet kubeadm kubectl containerd -y
apt-mark hold kubelet kubeadm kubectl
modprobe br_netfilter
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-arptables=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf
echo '1' > /proc/sys/net/ipv4/ip_forward


## на мастере
    ## внутренний адрес мастер-ноды
    ## сеть для подов
    ## внешний адрес мастер-ноды

kubeadm init \
    --apiserver-advertise-address=192.168.10.5 \
    --pod-network-cidr 10.244.0.0/16 \
    --apiserver-cert-extra-sans=62.84.125.100 \
mkdir $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml


## на воркерах

kubeadm join 192.168.10.5:6443 --token ut6oln.xrn3mf4m5rf4jlqt \
        --discovery-token-ca-cert-hash sha256:f81a18635a91c24c202310a652d4b813af51255583b2a1c247d8dfbacc5dd39c