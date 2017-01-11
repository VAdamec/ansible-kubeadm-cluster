#!/bin/bash

#
# System
#

rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
yum install -y facter unzip wget git bind-utils dbus-x11

#
# Prepare docker
#

cat <<EOF > /etc/yum.repos.d/docker.repo
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum install docker-engine-1.11.2 -y

mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF > /etc/systemd/system/docker.service.d/override.conf
  [Service]
  EnvironmentFile=-/etc/sysconfig/docker
  EnvironmentFile=-/etc/sysconfig/docker-storage
  EnvironmentFile=-/etc/sysconfig/docker-network
  ExecStart=
  ExecStart=/usr/bin/docker daemon -H fd:// $OPTIONS \
           $DOCKER_STORAGE_OPTIONS \
           $DOCKER_NETWORK_OPTIONS \
           $BLOCK_REGISTRY \
           $INSECURE_REGISTRY \
           --storage-driver=overlay
EOF

sudo tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF

modprobe overlay

systemctl daemon-reload
systemctl enable docker.service
systemctl start docker


#
# K8S
#

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl kubernetes-cni
systemctl enable kubelet && systemctl start kubelet
