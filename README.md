# Kubeadm Cluster with Vagrant

This is a collection of very simple and straight-forward scripts to deploy a kubeadm cluster with 1 master and 2 worker nodes using vagrant.
I wrote the scripts while I was experimenting and learning about the kubeadm. So keep your expectations low about the quality :)

This repo deploys a kubernetes cluster using the following technologies:
- Vagrant
- kubeadm
- flannel
- containerd

Note that, if you want to use this repo for yourself, you need to dig into the scripts and edit them according to your needs. There is barely
any configurations, but this also means it is (kinda) simpler to read. I plan to tidy up them in the future for better readibility and configurability.

You are always welcome to open any issues or pull requests!

## How to use this repository

You should always read the relavent documentations and you may possibly use this repository to ease your process of deploying a kubernetes cluster at home.

- First you should go through everything in the repo and edit the scripts according to your system and needs.
- Then you need to do a `vagrant up` and initialize the vms.
- Enter into the node-1 vm using `vagrant ssh`. If you use the vagrant shared folder feature, there should be the scripts in `/vagrant/` folder. 
- After this point, it is pretty straight-forward. You will run the scripts according to the following order and check the output.
    - install_packages.sh
    - install_containerd.sh
    - install_kubeadm.sh
- After you run the above scripts in each node, enter the master node and run the install_kubernetes.sh
- Check that the master node is ready and everything is allright. Then get the `kubeadm join` command from the output of the `kubeadm init`
- In worker nodes, run the install_kubernetes.sh script and at the end of the script, run the `kubeadm join` command that you got at the previous step.
- To test that everything is correct, test that you can create a pod and exec into it. 
