# Our mission

## Kubernetes HandsON LAB
```
.-----------------------------------------------------------------------.
| Build 3 control plane and 3 worker node K8s cluster. Solution should  |   
| has loadbalancer in front of API servers. For master nodes we need to |
| specify advertise IP address injected by Ansible. This hack is needed |
| to avoid issue with multiple linux network interfaces assigned to     |
| control planes! We have only 1 SPOF concerned loadbalancer. It can be |
| covered to use some HA for example RedHat cluster. This topic is out  |
| of scope and will be not covered in HandsON LAB.                      |
| Thank you!                                                            |
'-----------------------------------------------------------------------'
```

# Multiple controlplane, worker node cluster with load balancer
Welcome! This is small kubernetes cluster for testers and developers, that want to get to know
what Kubernetes is. LAb introduce redundancy for API server. You can use this code also
for education. It suits well when you have to perform fast tests and check if application is able
to work in K8s. It based on standard rpm installation. Please be patient during spin up cluster.
This proces can take a while up to 30 mins.

## Kubernetes version
Currently I'm using 1.19.3. Version is provided as ansible varabile stored separately for master, 
workers and loadbalancer in ansible playbook vars manifest file.

Feel free to change `version` if 1.19.3 does not satisfied your requirements.

## Avoiding Ansible installation
Due to fact that you may use different OS distribution for Vagrant host I decided
to use ansible_local provisioner instead of ansible. This approach let you avoid 
additional effort and save a lot of time in case of Ansible package installation.
Of curse on Linux this easy task but same thing is not so colorfull on Windows.
I would say it may be an nightmare ;-)  

## Requirements
Here will be short list about all requirements needed to run this environment.

+ Hardware:
  * 4 CPU
  * 10GB RAM
  * 60GB HDD (preferable SSD)

+ Operating system:
  * Widnows 10 installed WSL 1 preferable Ubuntu 18.04 LTS or 20.04 LTS (available in Microsoft Store)
  * Ubuntu 18.04 LTS or 20.04 LTS
  * CentOS/RHEL 7/8 64 bit preferable

`Sorry I have no time to check Debian and Suse.`   

+ Packages:
  * vagrant 2.2.10 or higher (https://www.vagrantup.com/intro/getting-started/install.html)
  * git 1.8 or higher for Linux / 2.29.2 or higher for Windows  (https://pl.atlassian.com/git/tutorials/install-git)
  * VirtualBox 6.1 or higher (https://www.virtualbox.org/wiki/Downloads)
  <!--- is not needed anymore cause I'm using ansible_local
  * Ansible 2.8 or higher (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
  --->

When your operating system is Windows please consider Cygwin installation. You have always alternative to install WSL1 or 2.

## Before you start
There are some prerequisite task which need to be completed before you start.

### Installing VirtualBox
From your laptop/desktop if you have 

CentOS 7.X/RHEL 7.X, CentOS 8.X/RHEL 8.X or Windows go through documentation. This topic goes beyound scope of this article!

Windows: https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1.16-140961-Win.exe
<br/>
Linux distributions: https://www.virtualbox.org/wiki/Linux_Downloads

<!--- is not needed anymore cause I'm using ansible_local
## Ansible installation
This Lab require ansible cause it is used for provisioning K8s cluster. If you have no anslibe please install it use below instructions:

### Redhat/CentOS
```
yum install -y ansible
```

### Ubuntu
```
apt-get install ansible
```

### Pip installation
```
pip install --user ansible
```
--->

### Windows
Please install WSL when you spin up lab on Windows machine. I recommend you to use 
Ubuntu 20.04 LTS. Be carefull and select proper WSL version! It should be always 
WSL 1 cause  WSL 2 is error prone! I would say more experimental. I faced cam across 
many troubles when I used WSL2 such as network connectivity issues related to ssh etc. 
Please put cloned repository out of /mnt/c and /mnt/d Windows directories. Why because 
Windows has own permission assignments! I advise to use Linux /home subsystem directory
otherwise you will be not able to use chmod commands.  

When you currently have WSL2 you need to convert it to WSL1.

List runs WSL distribution onboarded on your Windows Machine (please use powershell as Administrator)
```
wsl --list --verbose
```

Converting from WSL2 to WSL1
```
wsl --set-version <YOUR DISTRIBUTION> 1
```


`<YOUR DISTRIBUTION>`: is just output grabbed from previous command listing for example: Ubuntu-20.04

I highly encurage you to use Ubuntu 20.04 LTS!

## Items

+ Host entries:

```
172.16.0.2   k8s-master1
172.16.0.3   k8s-master2
172.16.0.4   k8s-master3
172.16.0.10  k8s-lb
172.16.0.20  k8s-worker1
172.16.0.21  k8s-worker2
172.16.0.22  k8s-worker2
```

`Don't need to be added to your /etc/hosts, in all cases we will use vagrant ssh command instead of standard ssh!`

+ Pods networking
```
Calico Networks
```

+ Kubernetes version
```
Kubernetes v1.19.3
```

+ Docker version
```
Docker version 19.03.12, build 48a66213fe
```

+ Operating system version
```
Ubuntu 20.04   LTS - Kubernetes itself
Ubuntu 18.04.5 LTS - HAProxy loadbalancer
```
+ Vagrant version
```
Vagrant 2.2.9
```

## Clone repo
How to clone repo? I'm sending you to documentation: https://confluence.atlassian.com/bitbucket/clone-a-repository-223217891.html

Please use following link to clone repository:

https://github.com/johnkk84/kubernetes-vagrant.git


In your home directory type:

```
git clone https://github.com/johnkk84/kubernetes-vagrant.git kubernetes-vagrant
```

Move to "kubernetes-vagrant" directory:

```
cd kubernetes-vagrant
```

## Start vagrant machines
When repo will be on your station then you need to run only 1 command.
You should be in kubernetes-vagrant directory. If not please enter this directory

run:

Run provisioning scripts one shoot setup.

***All hosts:***
```
./setup.sh -a
```

`
Please be patient this process can take a while usually depends on your hardware: disk speed, memory type,
cpu type and generation. 
`

Despite on 1 shot setup you can always select way 3 steps: 

***k8s-lb:***
Loadbalancer provisioning

```
./setup.sh -l
```


***k8s-master:***
Master nodes provisioning

```
./setup.sh -m
```

***k8s-worker1 & k8s-worker2 & k8s-worker3:***
Worker nodes provisioning

```
./setup.sh -w
```

You should see similar output:
```
Bringing machine 'k8s-master1' up with 'virtualbox' provider...
Bringing machine 'k8s-master2' up with 'virtualbox' provider...
Bringing machine 'k8s-master3' up with 'virtualbox' provider...
Bringing machine 'k8s-lb' up with 'virtualbox' provider...
Bringing machine 'k8s-worker1' up with 'virtualbox' provider...
Bringing machine 'k8s-worker2' up with 'virtualbox' provider...
Bringing machine 'k8s-worker3' up with 'virtualbox' provider...
==> k8s-master1: Importing base box 'centos/7'...
==> k8s-master1: Matching MAC address for NAT networking...
==> k8s-master1: Checking if box 'centos/7' version '2004.01' is up to date...
==> k8s-master1: Setting the name of the VM: master
==> k8s-master1: Clearing any previously set network interfaces...
==> k8s-master1: Preparing network interfaces based on configuration...
    k8s-master1: Adapter 1: nat
    k8s-master1: Adapter 2: hostonly
==> k8s-master1: Forwarding ports...
    k8s-master1: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master1: Running 'pre-boot' VM customizations...
.
..
...
==> k8s-master1: Running provisioner: shell...
    k8s-master1: Running: /tmp/vagrant-shell20200731-28936-1dpyuar.sh
    k8s-master1: .--- k8s lab ----.
    k8s-master1: |  Master Node 1 |
    k8s-master1: '----------------'
==> k8s-master1: Running provisioner: ansible...
    k8s-master1: Running ansible-playbook...

PLAY [all] *********************************************************************
.
..
...
TASK [push-join : debug] *******************************************************
ok: [k8s-worker3] => {
    "msg": "W0731 10:34:43.065611    6219 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.\n\t[WARNING IsDockerSystemdCheck]: detected \"cgroupfs\" as the Docker cgroup driver. The recommended driver is \"systemd\". Please follow the guide at https://kubernetes.io/docs/setup/cri/"
}

PLAY RECAP *********************************************************************
k8s-worker3                    : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

It can take a while, up to 20 mins. Please be patient.

Alternatively if you prefere you can just do it in one shoot:
```
./setup.sh -a
```

## Verification
From directory where Vagrantfile is located (kubernetes-vagrant) try connect to k8s-master and k8s-worker[1,2,3] 

### Check if machines are up and running
```
./setup -s
```

### Smoke test from 1st master node:


vagrant ssh k8s-master1

```
.--- k8s lab ---.
| Master Node 1 |
'---------------'
[vagrant@k8s-master1 ~]$ hostname
k8s-master1
```


### Test if you can connect use names:

```
# ping -c 1 k8s-master1
PING k8s-master (172.16.0.2) 56(84) bytes of data.
64 bytes from k8s-master1 (172.16.0.2): icmp_seq=1 ttl=64 time=0.202 ms

--- k8s-master1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.202/0.202/0.202/0.000 ms

# ping -c 1 k8s-master2
PING k8s-master2 (172.16.0.3) 56(84) bytes of data.
64 bytes from k8s-master2 (172.16.0.3): icmp_seq=1 ttl=64 time=0.202 ms

--- k8s-master2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.202/0.202/0.202/0.000 ms

# ping -c 1 k8s-master3
PING k8s-master3 (172.16.0.4) 56(84) bytes of data.
64 bytes from k8s-master3 (172.16.0.4): icmp_seq=1 ttl=64 time=0.202 ms

--- k8s-master3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.202/0.202/0.202/0.000 ms

# ping -c 1 k8s-worker1
PING k8s-worker1 (172.16.0.20) 56(84) bytes of data.
64 bytes from k8s-worker1 (172.16.0.20): icmp_seq=1 ttl=64 time=0.256 ms

--- k8s-worker1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.256/0.256/0.256/0.000 ms

$ ping -c 1 k8s-worker2
PING k8s-worker2 (172.16.0.21) 56(84) bytes of data.
64 bytes from k8s-worker2 (172.16.0.21): icmp_seq=1 ttl=64 time=0.256 ms

--- k8s-worker2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.256/0.256/0.256/0.000 ms

$ ping -c 1 k8s-worker3
PING k8s-worker3 (172.16.0.22) 56(84) bytes of data.
64 bytes from k8s-worker3 (172.16.0.22): icmp_seq=1 ttl=64 time=0.256 ms

--- k8s-worker3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.256/0.256/0.256/0.000 ms

ping -c 1 k8s-lb
PING k8s-lb (172.16.0.10) 56(84) bytes of data.
64 bytes from k8s-lb (172.16.0.10): icmp_seq=1 ttl=64 time=0.300 ms

--- k8s-lb ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.300/0.300/0.300/0.000 ms
```

You don't need to repeat this steps on other nodes cause it works on first master!

### List Kubernetes nodes
Kubectl binary has been installed only on master node. If you would like to use kubectl on your station you should install
it and copy configuration from .kubectl directory. Without kubectl you will be not able to check kubernetes status and
other cluster things.

On the master node: "k8s-master1" and vagrant user type:

```
kubectl get nodes
```

Then following output should be displayed:
```
NAME          STATUS   ROLES    AGE     VERSION
k8s-master1   Ready    master   7h24m   v1.19.3
k8s-master2   Ready    master   7h18m   v1.19.3
k8s-master3   Ready    master   7h9m    v1.19.3
k8s-worker1   Ready    worker   7h2m    v1.19.3
k8s-worker2   Ready    worker   6h54m   v1.19.3
k8s-worker3   Ready    worker   6h45m   v1.19.3
```

Please remember that you should see all nodes and masters as ready. If for some reason
nodes are unavailable please check kubelet logs.

### List Kubernetes cluster objects:
In this section we will check Kubernetes cluster in details. Thanks to this we will know if
all parts of cluster are ready for future operation/deployments etc.

#### Check Kubernetes cluster:"

Namespaces:
```
kubectl get namespaces
```

should return output:

```
NAME              STATUS   AGE
default           Active   45m
kube-node-lease   Active   45m
kube-public       Active   45m
kube-system       Active   45m
```


Pods in kube-system namespace:
```
kubectl --namespace kube-system get pods
```

You should see following output:

```
NAME                                  READY   STATUS    RESTARTS   AGE
calico-kube-controllers-6d7b4db76c-ddj8f   1/1     Running   3          7h12m
calico-node-2ht8p                          1/1     Running   4          7h12m
calico-node-5ccbg                          1/1     Running   4          6h46m
calico-node-b8ffb                          1/1     Running   3          7h10m
calico-node-czxw9                          1/1     Running   4          7h12m
calico-node-gb9s2                          1/1     Running   4          6h54m
calico-node-xw4rr                          1/1     Running   5          7h2m
coredns-f9fd979d6-bzfvx                    1/1     Running   3          7h24m
coredns-f9fd979d6-nk7xw                    1/1     Running   3          7h24m
etcd-k8s-master1                           1/1     Running   3          7h25m
etcd-k8s-master2                           1/1     Running   3          7h18m
etcd-k8s-master3                           1/1     Running   5          7h10m
kube-apiserver-k8s-master1                 1/1     Running   4          7h25m
kube-apiserver-k8s-master2                 1/1     Running   5          7h18m
kube-apiserver-k8s-master3                 1/1     Running   8          7h10m
kube-controller-manager-k8s-master1        1/1     Running   6          7h25m
kube-controller-manager-k8s-master2        1/1     Running   3          7h18m
kube-controller-manager-k8s-master3        1/1     Running   4          7h10m
kube-multus-ds-9wlxn                       1/1     Running   3          7h2m
kube-multus-ds-b6qsv                       1/1     Running   3          7h2m
kube-multus-ds-ffsht                       1/1     Running   3          7h2m
kube-multus-ds-gw47r                       1/1     Running   4          6h46m
kube-multus-ds-jbxpn                       1/1     Running   4          6h54m
kube-multus-ds-n944z                       1/1     Running   4          7h2m
kube-proxy-7tmkk                           1/1     Running   4          7h2m
kube-proxy-jdvs2                           1/1     Running   4          6h54m
kube-proxy-kch2b                           1/1     Running   3          7h10m
kube-proxy-rmnf9                           1/1     Running   4          6h46m
kube-proxy-sff8g                           1/1     Running   3          7h18m
kube-proxy-xkvb2                           1/1     Running   3          7h24m
kube-scheduler-k8s-master1                 1/1     Running   4          7h25m
kube-scheduler-k8s-master2                 1/1     Running   3          7h18m
kube-scheduler-k8s-master3                 1/1     Running   4          7h10m
```

Deployments in kube-system namespace:
```
kubectl --namespace kube-system get deployments
```

Desired output:

```
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
calico-kube-controllers   1/1     1            1           7h12m
coredns                   2/2     2            2           7h25m
```

## Used technology:
- Ansible
- Kubernetes
- Vagrant
- Git
- Github

## Post installation steps
There is always good ida to have lab hosts in /etc/hosts file. It can be usefull in many cases 
(reach loadbalancer, check if ingress or application is running on the nodes and scheduled
properly).

If you are intrested please go as follow:

```
cat <<EOT >> /etc/hosts
172.16.0.2   k8s-master1 
172.16.0.3   k8s-master2
172.16.0.4   k8s-master3
172.16.0.10  k8s-lb
172.16.0.20  k8s-worker1
172.16.0.21  k8s-worker2
172.16.0.22  k8s-worker3
EOT
```

### Trouble shooting

Windows powershell: stop ruby and vagrant processes:
```
Stop-process -Name ruby 
Stop-Process -Name vagrant
```

Windows powershell: Search ruby and vagrant process:
```
Get-Process -Name ruby
Get-Process -Name vagrant
```

## Kubernetes applications

### Nginx ingress controller as default

### Service Mesh Istio

### Portworx as dynamic storage volume provisioner

More details about manage processes using powershell you can find under blow link:

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-process?view=powershell-7.1

Thank you!

### To Do
- [ ] Spin up portworx cluster using daemonset yaml file
- [ ] Add nginx Ingress controller as default controller
- [ ] Setup frontend based on flask for course presentation
- [x] Correct output of commands
- [x] Provision 2nd and 3rd master node and rename k8s-master to k8s-master1
- [x] Provision HAProxy loadbalancer correspond to 2 master nodes k8s-master1 and k8s-master2
- [x] One hadshoot provisioner script
- [x] Add apps directory synchronization to each of cluster node
- [x] Replace Ansible on vagrant host using anslible_local on each vagrant vm (PARTIALY DONE)
- [x] Reduce unnecessary steps for disk creation. Extra storage need to be provide only for workers vms