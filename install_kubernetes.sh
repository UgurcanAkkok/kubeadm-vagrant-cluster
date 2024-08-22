#!/bin/bash
set -xe -o pipefail

if [ "$HOSTNAME" == "node-1" ]; then
  NODE_IP="192.168.60.201"
  ARGS_KUBEADM_INIT=""
  ARGS_KUBEADM_INIT="$ARGS_KUBEADM_INIT --pod-network-cidr=10.244.0.0/16" # flannel default
  ARGS_KUBEADM_INIT="$ARGS_KUBEADM_INIT --apiserver-advertise-address ${NODE_IP}"
  #ARGS_KUBEADM_INIT="$ARGS_KUBEADM_INIT --node-ip ${NODE_IP}"
  # ARGS_KUBEADM_INIT="$ARGS_KUBEADM_INIT --feature-gates=KubeletCgroupDriverFromCRI=true,GracefulNodeShutdown=true"

  echo "Enabling ipv4 packet forwarding.."
  sed -i '/net.ipv4.ip_forward=1/ s/#//' /etc/sysctl.conf
  echo "1" | tee /proc/sys/net/ipv4/ip_forward
  echo "KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}" > /etc/default/kubelet
  kubeadm init $ARGS_KUBEADM_INIT

  mkdir -p /home/vagrant/.kube
  sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config
  # Deploy flannel
  # Fix for https://github.com/flannel-io/flannel/blob/master/Documentation/troubleshooting.md#vagrant, use eth1 interface
  curl -Ls https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml | sed '/- --ip-masq/ a \        - --iface=eth1' | kubectl apply -f -
else 
  echo "Not master node"
  NODE_IP="$(ip add show eth1 | grep "inet " | sed -r 's/\s*inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/')"

  echo "Enabling ipv4 packet forwarding.."
  sed -i '/net.ipv4.ip_forward=1/ s/#//' /etc/sysctl.conf
  echo "1" | tee /proc/sys/net/ipv4/ip_forward
  echo "KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}" > /etc/default/kubelet

  echo "Execute the kubeadm join command.."
fi
