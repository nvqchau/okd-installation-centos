# okd-installation-centos

![OKD](https://lh3.googleusercontent.com/OBGT85EIBjT43vxUsI0Pmhl68NmYxqOUbBuTjRivjP24t5r38ft0ioTNuEV0IAyV3izoadJsdYIlnw)

# About...

_This repository is used to create **OKD 3.11 Clusters** with **12** simple steps on **Bare VM's**_

# Table of Contents

- [What are the pre-requisites ?](#prerequisites)
- [What are the VM's provisioned ?](#configuration)
- [How to deploy okd clusters ?](#deploy)
- [How to access okd Console ?](#console)
- [What are the addons provided ?](#addons)

<a id="prerequisites"></a>

# What are the prerequisites ?

- [Git](https://git-scm.com/downloads 'Git')

<a id="configuration"></a>

# What are the VM's provisioned ?

> **_Note: We are not going to create any VM's during this process. User is expected to have VM's before proceeding with this repository_**

_Below is the **example configuration** that we are going to refer **through out this repository**._

| _Name_                              | _IP_            | _OS_      | _RAM_ | _CPU_ | _Storage_ |
| ----------------------------------- | --------------- | --------- | ----- | ----- | --------- |
| _okd-master1.192.168.1.100.nip.io_  | _192.168.1.100_ | _CentOS7_ | _4GB_ | _2_   | _40GB_    |
| _okd-infra1.192.168.1.105.nip.io_   | _192.168.1.105_ | _CentOS7_ | _4GB_ | _2_   | _40GB_    |
| _okd-compute1.192.168.1.110.nip.io_ | _192.168.1.110_ | _CentOS7_ | _1GB_ | _1_   | _20GB_    |
| _okd-compute2.192.168.1.111.nip.io_ | _192.168.1.111_ | _CentOS7_ | _1GB_ | _1_   | _20GB_    |
| _okd-compute3.192.168.1.112.nip.io_ | _192.168.1.112_ | _CentOS7_ | _1GB_ | _1_   | _20GB_    |

<a id="deploy"></a>

# How to deploy openshift clusters ?

## **_Step 1_**

**_Update the host names for all nodes_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`
- `192.168.1.105 (okd-infra1.192.168.1.105.nip.io)`
- `192.168.1.110 (okd-compute1.192.168.1.110.nip.io)`
- `192.168.1.111 (okd-compute2.192.168.1.111.nip.io)`
- `192.168.1.112 (okd-compute3.192.168.1.112.nip.io)`

When you set up a cluster that is not integrated with a cloud provider, you must correctly set your nodes' host names. Each node’s host name must be resolvable, and each node must be able to reach each other node.

```
$ vi /etc/hostname

**_(OR)_**

$ nmtui hostname
```

## **_Step 2: DNS Requirements_**

**_Update the system all nodes_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`
- `192.168.1.105 (okd-infra1.192.168.1.105.nip.io)`
- `192.168.1.110 (okd-compute1.192.168.1.110.nip.io)`
- `192.168.1.111 (okd-compute2.192.168.1.111.nip.io)`
- `192.168.1.112 (okd-compute3.192.168.1.112.nip.io)`

OKD requires a fully functional DNS server in the environment. This is ideally a separate host running DNS software and can provide name resolution to hosts and containers running on the platform.

> _Warning: Adding entries into the /etc/hosts file on each host is not enough. This file is not copied into containers running on the platform._
>
> **_In this example, we use [nip.io](https://nip.io/) service._**

Key components of OKD run themselves inside of containers and use the following process for name resolution:

1. By default, containers receive their DNS configuration file (/etc/resolv.conf) from their host.
2. OKD then sets the pod’s first nameserver to the IP address of the node.

As of OKD 1.2, **dnsmasq** is automatically configured on all masters and nodes. The pods use the nodes as their DNS, and the nodes forward the requests. By default, **dnsmasq** is configured on the nodes to listen on port 53, therefore the nodes cannot run any other type of DNS application.

> _**NetworkManager**, a program for providing detection and configuration for systems to automatically connect to the network, is required on the nodes in order to populate **dnsmasq** with the DNS IP addresses._
>
> _**NM_CONTROLLED** is set to yes by default. If **NM_CONTROLLED** is set to **no**, then the NetworkManager dispatch script does not create the relevant **origin-upstream-dns.conf** dnsmasq file, and you must configure dnsmasq manually._
>
> _Similarly, if the **PEERDNS** parameter is set to no in the network script, for example, **/etc/sysconfig/network-scripts/ifcfg-em1**, then the dnsmasq files are not generated, and the Ansible install will fail. Ensure the **PEERDNS** setting is set to **yes**._

The following is an example set of DNS records:

    master1    A   10.64.33.100
    master2    A   10.64.33.103
    node1      A   10.64.33.101
    node2      A   10.64.33.102

If you do not have a properly functioning DNS environment, you might experience failure with:

- Product installation via the reference Ansible-based scripts
- Deployment of the infrastructure containers (registry, routers)
- Access to the OKD web console, because it is not accessible via IP address alone

## **_Step 3: Configuring hosts to use DNS for all nodes_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`
- `192.168.1.105 (okd-infra1.192.168.1.105.nip.io)`
- `192.168.1.110 (okd-compute1.192.168.1.110.nip.io)`
- `192.168.1.111 (okd-compute2.192.168.1.111.nip.io)`
- `192.168.1.112 (okd-compute3.192.168.1.112.nip.io)`

Make sure each host in your environment is configured to resolve hostnames from your DNS server. The configuration for hosts' DNS resolution depend on whether DHCP is enabled. If DHCP is:

- Disabled, then configure your network interface to be static, and add DNS nameservers to NetworkManager.
- Enabled, then the NetworkManager dispatch script automatically configures DNS based on the DHCP configuration.

To verify that hosts can be resolved by your DNS server:

1.  Check the contents of /etc/resolv.conf:

    ```
    $ cat /etc/resolv.conf
    search nip.io
    nameserver 8.8.8.8
    ```

    In this example, `8.8.8.8` is the address of our DNS server.

2.  Test that the DNS servers listed in **/etc/resolv.conf** are able to resolve host names to the IP addresses of all nodes in your OKD environment:

    ```
    $ dig <node_hostname> @<IP_address> +short
    ```

    For example:

    ```
    $ dig okd-master1.192.168.1.100.nip.io @8.8.8.8 +short
    192.168.1.100

    $ dig okd-compute1.192.168.1.110.nip.io @8.8.8.8 +short
    192.168.1.110
    ```

## **_Step 4_**

**_Enable SELINUX=enforcing on all nodes_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`
- `192.168.1.105 (okd-infra1.192.168.1.105.nip.io)`
- `192.168.1.110 (okd-compute1.192.168.1.110.nip.io)`
- `192.168.1.111 (okd-compute2.192.168.1.111.nip.io)`
- `192.168.1.112 (okd-compute3.192.168.1.112.nip.io)`

```
$ vi /etc/selinux/config
```

_We can verify the status by running the below command. The correct status will not reflect once we changed until we reboot the machines_

```
$ sestatus
```

## **_Step 5: Reboot all nodes_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`
- `192.168.1.105 (okd-infra1.192.168.1.105.nip.io)`
- `192.168.1.110 (okd-compute1.192.168.1.110.nip.io)`
- `192.168.1.111 (okd-compute2.192.168.1.111.nip.io)`
- `192.168.1.112 (okd-compute3.192.168.1.112.nip.io)`

```
$ reboot
```

## **_Step 6: Prepare environment variables for all nodes_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`
- `192.168.1.105 (okd-infra1.192.168.1.105.nip.io)`
- `192.168.1.110 (okd-compute1.192.168.1.110.nip.io)`
- `192.168.1.111 (okd-compute2.192.168.1.111.nip.io)`
- `192.168.1.112 (okd-compute3.192.168.1.112.nip.io)`

**_Checkout the code "okd-installation-centos" folder_**

_Example to root folder and execution permissions can be applied by executing the below command._

```
$ git clone https://github.com/nvqchau/okd-installation-centos.git

$ chmod +x -R okd-installation-centos
```

**_Edit okd-installation-centos/provisioning/settings.sh file_**

```
#!/bin/bash
#The below configuration can be edited up on your needs and and please note the it's just an example configuration.
#We are going to create an OKD cluster with one master and 3 worker nodes.

#OKD Version
export OKD_VERSION=3.11

#OKD Master Node 1 Configuration
export OKD_MASTER_NODE_1_IP=192.168.1.100
export OKD_MASTER_NODE_1_SUBDOMAIN=okd-master1
export OKD_MASTER_NODE_1_HOSTNAME=okd-master1.192.168.1.100.nip.io

#OKD Infra Node 1 Configuration
export OKD_INFRA_NODE_1_IP=192.168.1.105
export OKD_INFRA_NODE_1_SUBDOMAIN=okd-infra1
export OKD_INFRA_NODE_1_HOSTNAME=okd-infra1.192.168.1.105.nip.io

#OKD Worker Node 1 Configuration
export OKD_WORKER_NODE_1_IP=192.168.1.110
export OKD_WORKER_NODE_1_SUBDOMAIN=okd-compute1
export OKD_WORKER_NODE_1_HOSTNAME=okd-compute1.192.168.1.110.nip.io

#OKD Worker Node 2 Configuration
export OKD_WORKER_NODE_2_IP=192.168.1.111
export OKD_WORKER_NODE_2_SUBDOMAIN=okd-compute2
export OKD_WORKER_NODE_2_HOSTNAME=okd-compute2.192.168.1.111.nip.io

#OKD Worker Node 3 Configuration
export OKD_WORKER_NODE_3_IP=192.168.1.112
export OKD_WORKER_NODE_3_SUBDOMAIN=okd-compute3
export OKD_WORKER_NODE_3_HOSTNAME=okd-compute3.192.168.1.112.nip.io

#The  below setting will be used to access OKD console https://console.$DOMAIN:$API_PORT
#By default we can login using the URL https://console.okd.nip.io:8443
#To access URL from your local system we need to configure master host in C:\Windows\System32\drivers\etc\hosts (Windows) or /private/etc/hosts (MacOS) file as below
#192.168.1.100    console.okd.nip.io

export DOMAIN=okd.nip.io
export API_PORT=8443

#OKD Login Credentials
#By default admin/admin operator will be created and can be used to login to OKD console.
export OKD_USERNAME=admin
export OKD_PASSWORD=admin

#OKD Add-Ons
#Enable "True"  only if one of the VM has 4GB memory.
export INSTALL_METRICS=False

# Enable "True"  only one of the VM 16GB memory. 
export INSTALL_LOGGING=False
```

## **_Step 7:_**

**_Execute the below script on all nodes_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`
- `192.168.1.105 (okd-infra1.192.168.1.105.nip.io)`
- `192.168.1.110 (okd-compute1.192.168.1.110.nip.io)`
- `192.168.1.111 (okd-compute2.192.168.1.111.nip.io)`
- `192.168.1.112 (okd-compute3.192.168.1.112.nip.io)`

```
$ ./okd-installation-centos/provisioning/install_prerequisites.sh
```

## **_Step 8: Reboot all nodes_**

**_Execute the below script on all nodes_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`
- `192.168.1.105 (okd-infra1.192.168.1.105.nip.io)`
- `192.168.1.110 (okd-compute1.192.168.1.110.nip.io)`
- `192.168.1.111 (okd-compute2.192.168.1.111.nip.io)`
- `192.168.1.112 (okd-compute3.192.168.1.112.nip.io)`

```
$ reboot
```

## **_Step 9: Check if all nodes can talk to each others_**

**_Execute the below script on all nodes_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`
- `192.168.1.105 (okd-infra1.192.168.1.105.nip.io)`
- `192.168.1.110 (okd-compute1.192.168.1.110.nip.io)`
- `192.168.1.111 (okd-compute2.192.168.1.111.nip.io)`
- `192.168.1.112 (okd-compute3.192.168.1.112.nip.io)`

To confirm that a node can reach another node:

1.  On one node, obtain the host name:

    ```
    $ hostname
    okd-master1.192.168.1.100.nip.io
    ```

2.  On that same node, obtain the fully qualified domain name of the host:

    ```
    $ hostname -f
    okd-master1.192.168.1.100.nip.io
    ```

3.  From a different node, confirm that you can reach the first node:

    ```
    $ ping okd-master1.192.168.1.100.nip.io -c 1
    PING okd-master1.192.168.1.100.nip.io (192.168.1.100): 56 data bytes
    64 bytes from 192.168.1.100: icmp_seq=0 ttl=64 time=0.573 ms
    
    --- okd-master1.192.168.1.100.nip.io ping statistics ---
    1 packets transmitted, 1 packets received, 0.0% packet loss
    round-trip min/avg/max/stddev = 0.573/0.573/0.573/0.000 ms
    ```

All three steps could be replaced by run the `ping.sh` command file

```
$ ./okd-installation-centos/provisioning/ping.sh
PING okd-master1.192.168.1.100.nip.io (192.168.1.100): 56 data bytes
64 bytes from 192.168.1.100: icmp_seq=0 ttl=64 time=1.040 ms

--- okd-master1.192.168.1.100.nip.io ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 1.040/1.040/1.040/0.000 ms

PING okd-infra1.192.168.1.105.nip.io (192.168.1.105): 56 data bytes
64 bytes from 192.168.1.105: icmp_seq=0 ttl=64 time=1.078 ms

--- okd-infra1.192.168.1.105.nip.io ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 1.078/1.078/1.078/0.000 ms

PING okd-compute1.192.168.1.110.nip.io (192.168.1.110): 56 data bytes
64 bytes from 192.168.1.110: icmp_seq=0 ttl=64 time=0.708 ms

--- okd-compute1.192.168.1.110.nip.io ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.708/0.708/0.708/0.000 ms

PING okd-compute2.192.168.1.111.nip.io (192.168.1.111): 56 data bytes
64 bytes from 192.168.1.111: icmp_seq=0 ttl=64 time=0.530 ms

--- okd-compute2.192.168.1.111.nip.io ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.530/0.530/0.530/0.000 ms

PING okd-compute3.192.168.1.112.nip.io (192.168.1.112): 56 data bytes
64 bytes from 192.168.1.112: icmp_seq=0 ttl=64 time=0.543 ms

--- okd-compute3.192.168.1.112.nip.io ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.543/0.543/0.543/0.000 ms
```

## **_Step 10:_**

**_Enable SSH to communicate all the other "worker/infra nodes" from "master" without "password". All the below commands needs to be executed on "master" node only_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`

```
$ ssh-keygen

$ ssh-copy-id 192.168.1.100

$ ssh-copy-id 192.168.1.105

$ ssh-copy-id 192.168.1.110

$ ssh-copy-id 192.168.1.111

$ ssh-copy-id 192.168.1.112
```

## **_Step 11:_**

**_Execute the below script on "master" node only_**

- `192.168.1.100 (okd-master1.192.168.1.100.nip.io)`

```
$ ./okd-installation-centos/provisioning/install_master.sh
```

## **_Step 12_**

**_Verify okd installation is success by executing below two commands to see all the nodes and pods._**

```
$ oc login -u admin -p admin https://console.okd.nip.io:8443

$ oc get projects
```

<a id="console"></a>

# How to access okd Console ?

The **_okd console_** can be accessed via the below URL from your local machine

- [`https://console.okd.nip.io:8443`](https://console.okd.nip.io:8443)

> The below setting will be used to access OKD console `https://console.$DOMAIN:$API_PORT`.
>
> By default we can login using the URL https://console.okd.nip.io:8443
>
> To access URL from your local system we need to configure master host in C:\Windows\System32\drivers\etc\hosts (Windows) or /private/etc/hosts (MacOS) file as below
>
> `192.168.1.100 console.okd.nip.io`

<a id="addons"></a>

# What are the addons provided ?

- `helm`
