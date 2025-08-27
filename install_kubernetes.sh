#!/bin/bash
set -xe -o pipefail

if [ "$UID" != "0" ]; then
  echo "You need to be root"
  exit 1
fi

echo "Disabling swap."
swapoff -a
sed -i '/swap/ d' /etc/fstab

if [ "$HOSTNAME" == "node-1" ]; then
  NODE_IP="$(hostname -I)"
  ARGS_KUBEADM_INIT=""
  ARGS_KUBEADM_INIT="$ARGS_KUBEADM_INIT --pod-network-cidr=10.244.0.0/16" # flannel default
  ARGS_KUBEADM_INIT="$ARGS_KUBEADM_INIT --apiserver-advertise-address ${NODE_IP}"
  #ARGS_KUBEADM_INIT="$ARGS_KUBEADM_INIT --node-ip ${NODE_IP}"
  # ARGS_KUBEADM_INIT="$ARGS_KUBEADM_INIT --feature-gates=KubeletCgroupDriverFromCRI=true,GracefulNodeShutdown=true"

  echo "Enabling ipv4 packet forwarding.."
  sed -i '/net.ipv4.ip_forward=1/ s/#//' /etc/sysctl.conf
  echo "1" | tee /proc/sys/net/ipv4/ip_forward
  echo "KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}" >/etc/default/kubelet
  kubeadm init $ARGS_KUBEADM_INIT

  mkdir -p /home/vagrant/.kube
  cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config
  # Deploy flannel
  # Fix for https://github.com/flannel-io/flannel/blob/master/Documentation/troubleshooting.md#vagrant, use eth1 interface
  curl -Ls https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml | sed '/- --ip-masq/ a \        - --iface=eth0' | kubectl apply -f -
  # Flannel fails to read /proc/sys/net/bridge/bridge-nf-call-iptables, so we need this kernel module
  echo 'br_netfilter' >/etc/modules-load.d/br_netfilter.conf
  sudo modprobe br_netfilter
else
  echo "Not master node"
  NODE_IP="$(hostname -I)"

  echo "Enabling ipv4 packet forwarding.."
  sed -i '/net.ipv4.ip_forward=1/ s/#//' /etc/sysctl.conf
  echo "1" | tee /proc/sys/net/ipv4/ip_forward
  echo "KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}" >/etc/default/kubelet

  echo "Execute the kubeadm join command.."
fi
