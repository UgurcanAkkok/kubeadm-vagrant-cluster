#!/bin/bash
set -xe -o pipefail

## This script follows the https://github.com/containerd/containerd/blob/main/docs/getting-started.md and https://kubernetes.io/docs/setup/production-environment/container-runtimes/
## and relevant resources for installing containerd and accompanying binaries to a debian/bookworm VM

arch="amd64"

containerd_version="1.6.35"
containerd_url="https://github.com/containerd/containerd/releases/download/v${containerd_version}/containerd-${containerd_version}-linux-${arch}.tar.gz"
containerd_sum_url="https://github.com/containerd/containerd/releases/download/v${containerd_version}/containerd-${containerd_version}-linux-${arch}.tar.gz.sha256sum"
containerd_targz="containerd-${containerd_version}-linux-${arch}.tar.gz"

runc_version="1.1.13"
runc_url="https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.${arch}"
runc_binary="runc.${arch}"

cni_version="1.5.1"
cni_url="https://github.com/containernetworking/plugins/releases/download/v${cni_version}/cni-plugins-linux-${arch}-v${cni_version}.tgz"
cni_sum_url="https://github.com/containernetworking/plugins/releases/download/v${cni_version}/cni-plugins-linux-${arch}-v${cni_version}.tgz.sha256"
cni_targz="cni-plugins-linux-${arch}-v${cni_version}.tgz"

nerdctl_version="1.7.6"
nerdctl_url="https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/nerdctl-${nerdctl_version}-linux-${arch}.tar.gz"
nerdctl_targz="nerdctl-${nerdctl_version}-linux-${arch}.tar.gz"

install_containerd(){
  if ! command -v containerd &> /dev/null; then 
    cd $(mktemp -d)
    wget $containerd_url 
    wget $containerd_sum_url
    sha256sum --check $containerd_targz.sha256sum
    tar Cxzvf /usr/local $containerd_targz
    cd -

    mkdir -p /usr/local/lib/systemd/system/
    curl -o /usr/local/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

  fi

  mkdir -p /etc/containerd
  containerd config default > /etc/containerd/config.toml
  # Change the option under the [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  # TODO: this should be a more accurate find and replace
  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

  systemctl daemon-reload
  systemctl enable --now containerd

}

install_runc(){
  if ! command -v runc &> /dev/null; then
    cd $(mktemp -d)
    wget $runc_url
    install -m 755 ${runc_binary} /usr/local/sbin/runc
    cd -
  fi
}

install_cni(){
  if ! [ -d "/opt/cni/bin" ]; then
    cd $(mktemp -d)
    wget $cni_url
    wget $cni_sum_url
    sha256sum --check $cni_targz.sha256

    mkdir -p /opt/cni/bin
    tar Cxzvf /opt/cni/bin $cni_targz
    cd -
  fi
}

install_nerdctl(){
  if ! command -v nerdctl &> /dev/null; then
    cd $(mktemp -d)
    wget $nerdctl_url
    tar Cxzvvf /usr/local/bin $nerdctl_targz
    cd -
  fi
}

install_containerd
install_runc
install_cni
install_nerdctl
