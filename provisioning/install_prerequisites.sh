#!/bin/bash

source ${BASH_SOURCE%/*}/settings.sh

cat >>/etc/hosts<<EOF
${OKD_MASTER_NODE_1_IP} ${OKD_MASTER_NODE_1_HOSTNAME} ${OKD_MASTER_NODE_1_SUBDOMAIN} console console.${DOMAIN}
${OKD_WORKER_NODE_1_IP} ${OKD_WORKER_NODE_1_HOSTNAME} ${OKD_WORKER_NODE_1_SUBDOMAIN}
${OKD_WORKER_NODE_2_IP} ${OKD_WORKER_NODE_2_HOSTNAME} ${OKD_WORKER_NODE_2_SUBDOMAIN}
${OKD_WORKER_NODE_3_IP} ${OKD_WORKER_NODE_3_HOSTNAME} ${OKD_WORKER_NODE_3_SUBDOMAIN}

EOF

# install the following base packages
yum install -y wget
yum install -y envsubst
yum install -y figlet
yum install -y git
yum install -y zile
yum install -y nano
yum install -y net-tools
yum install -y bind-utils iptables-services
yum install -y bridge-utils bash-completion
yum install -y kexec-tools
yum install -y sos
yum install -y psacct
yum install -y openssl-devel
yum install -y httpd-tools
yum install -y NetworkManager
yum install -y python-cryptography
yum install -y python2-pip
yum install -y python-devel
yum install -y python-passlib
yum install -y java-1.8.0-openjdk-headless "@Development Tools"

yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io

# Update the system to the latest packages
yum update -y

# Install the EPEL repository
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Disable the EPEL repository globally so that is not accidentally used during later steps of the installation
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

systemctl | grep "NetworkManager.*running"
if [ $? -eq 1 ]; then
        systemctl start NetworkManager
        systemctl enable NetworkManager
fi

systemctl restart docker
systemctl enable docker