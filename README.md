# okd-installation-centos

![OKD](https://lh3.googleusercontent.com/OBGT85EIBjT43vxUsI0Pmhl68NmYxqOUbBuTjRivjP24t5r38ft0ioTNuEV0IAyV3izoadJsdYIlnw)

# About...

\* This repository is used to create **_OKD 3.11 Cluster_** with **9** simple steps on **\*Bare VM's\*\***

# Table of Contents

- [What are the pre-requisites ?](#prerequisites)
- [What are the VM's provisioned ?](#configuration)
- [How to deploy okd cluster ?](#deploy)
- [How to access okd Console ?](#console)
- [What are the addons provided ?](#addons)

<a id="prerequisites"></a>

# What are the prerequisites ?

- [Git](https://git-scm.com/downloads 'Git')

<a id="configuration"></a>

# What are the VM's provisioned ?

**_Note: We are not going to create any VM's during this process. User is expected to have VM's before proceeding with this repository_**

\* Below is the **_example configuration_** that we are going to refer **_through out this repository_**.\*

| _Name_              | _IP_            | _OS_      | _RAM_ | _CPU_ | _Storage_ |
| ------------------- | --------------- | --------- | ----- | ----- | --------- |
| _okd-master-node-1_ | _100.10.10.100_ | _CentOS7_ | _1GB_ | _1_   | _24GB_    |
| _okd-infra-node-1_  | _100.10.10.101_ | _CentOS7_ | _1GB_ | _1_   | _24GB_    |
| _okd-worker-node-1_ | _100.10.10.102_ | _CentOS7_ | _1GB_ | _1_   | _24GB_    |

<a id="deploy"></a>

# How to deploy openshift cluster ?

## **_Step 1_**

**_Update the system and host names for all nodes_**

- `100.10.10.100 (okd-master-node-1)`
- `100.10.10.101 (okd-infra-node-1)`
- `100.10.10.102 (okd-worker-node-1)`

**_Unix Command!!!_**

`$ sudo yum update -y`

`$ sudo vi /etc/hostname` **_(OR)_** `$ sudo nmtui hostname`

## **_Step 2_**

**_Enable SELINUX=enforcing on all master/worker/infra nodes_**

- `100.10.10.100 (okd-master-node-1)`
- `100.10.10.101 (okd-infra-node-1)`
- `100.10.10.102 (okd-worker-node-1)`

**_Unix Command!!!_**

`$ sudo vi /etc/selinux/config`

**_We can verify the status by running the below command. The correct status will not reflect once we changed until we reboot the machines_**

`$ sudo sestatus`

## **_Step 3_**

**_Reboot all master/worker/infra nodes_**

- `100.10.10.100 (okd-master-node-1)`
- `100.10.10.101 (okd-infra-node-1)`
- `100.10.10.102 (okd-worker-node-1)`

**_Unix Command!!!_**

`$ sudo reboot`

## **_Step 4_**

_Checkout the code (git clone https://github.com/nvqchau/okd-installation-centos.git)_

**_Configure okd-installation-centos/provisioning/settings.sh file_**
![enter image description here](https://lh3.googleusercontent.com/zbeRg_vHfpg0iG0w70E0u6T-PEfK8czIN7FywGoaTOyo-giHgYI8ABg7s8WQOINds4sFNDbvkWqyZQ)

## **_Step 5_**

**_Copy "okd-installation-centos" folder to all master/worker nodes_**

- `100.10.10.100 (okd-master-node-1)`
- `100.10.10.101 (okd-infra-node-1)`
- `100.10.10.102 (okd-worker-node-1)`

_Example copy to root folder and execution permissions can be applied by executing the below command._

**_Unix Command!!!_**

`$ chmod +x -R okd-installation-centos`

## **_Step 6_**

**_Execute the below script on all master/worker/infra nodes_**

- `100.10.10.100 (okd-master-node-1)`
- `100.10.10.101 (okd-infra-node-1)`
- `100.10.10.102 (okd-worker-node-1)`

**_Unix Command!!!_**

`$ sudo okd-installation-centos/provisioning/install_prerequisites.sh`

## **_Step 7_**

**_Enable SSH to communicate all the other "worker/infra nodes" from "master" without "password". All the below commands needs to be executed on "master" node only_**

- `100.10.10.100 (okd-master-node-1)`

**_Unix Command!!!_**

`$ ssh-keygen -t rsa`

**_okd-master-node-1_**

`$ cat ~/.ssh/id_rsa.pub | ssh root@100.10.10.100 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`

**_okd-infra-node-1_**

`$ cat ~/.ssh/id_rsa.pub | ssh root@100.10.10.101 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`

**_okd-worker-node-1_**

`$ cat ~/.ssh/id_rsa.pub | ssh root@100.10.10.102 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`

## **_Step 8_**

**_Execute the below script only on master node_**

- `100.10.10.100 (okd-master-node-1)`

**_Unix Command!!!_**

`$ sudo okd-installation-centos/provisioning/install_master.sh`

## **_Step 9_**

**_Verify okd installation is success by executing below two commands to see all the nodes and pods._**

**_Unix Command!!!_**

`$ oc login -u admin -p admin https://console.okd.nip.io:8443`

`$ oc get projects`

<a id="console"></a>

# How to access okd Console ?

The **_okd Console_** can be accessed via the below URL from your local machine

[https://console.okd.nip.io:8443](https://console.okd.nip.io:8443)

<a id="addons"></a>

# What are the addons provided ?

- `helm`
