#!/bin/bash
set -xe -o pipefail

### This script follows the https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
### to install kubeadm and relavent packages.

kubernetes_version="1.31"

# Get the signing key
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${kubernetes_version}/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the apt repo
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${kubernetes_version}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

# Install the packages and pin their version

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet
