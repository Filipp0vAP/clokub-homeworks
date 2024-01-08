#/bin/bash

## на мастере
    ## внутренний адрес мастер-ноды
    ## сеть для подов
    ## внешний адрес мастер-ноды

kubeadm init \
    --apiserver-advertise-address=192.168.10.30 \
    --pod-network-cidr 10.244.0.0/16 \
    --apiserver-cert-extra-sans=51.250.79.71 \

mkdir $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
