# Kubeadm Cluster with Vagrant

This is a collection of very simple and straight-forward scripts to deploy a kubeadm cluster with 1 master and 2 worker nodes using vagrant.
I wrote the scripts while I was experimenting and learning about the kubeadm. So keep your expectations low about the quality :)

This repo deploys a kubernetes cluster using the following technologies:
- Vagrant
- kubeadm
- flannel
- containerd

Note that, if you want to use this repo for yourself, you need to dig into the scripts and edit them according to your needs. There is barely
any configuratins, but this also means it is (kinda) simpler to read. I plan to tidy up them in the future for better readibility and configurability.

You are always welcome to open any issues or pull requests!
