# Our mission

## Kubernetes HandsON LAB
```
.-----------------------------------------------------------------------.
| Build 3 control plane and 3 worker node K8s cluster. Solution should  |   
| has loadbalancer in front of API servers. For master nodes we need to |
| specify advertise IP address injected by Ansible. This hack is needed |
| to avoid issue with multiple linux network interfaces assigned to     |
| control planes!                                                       |
'-----------------------------------------------------------------------'
```

# Three node Vagrant Kubernetes Cluster
Welcome! This is small kubernetes cluster for testers and developers. You can use this code also
for education. It suits well when you have to perform fast tests and check if application is able
to work in K8s. It based on standard rpm installation.

## Kubernetes version
Currently I'm using 1.18.6. Version is provided as ansible varabile stored separately for master, 
workers and loadbalancer in ansible playbook vars manifest file.

Feel free to change `version` if 18.0.6 does not satisfied you.

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
  * 8GB RAM
  * 60GB HDD (preffered SSD)

+ Operating system:
  * Widnows 10 installed WSL 1 preferable Ubuntu 18.04 LTS or 20.04 LTS (available in Microsoft Store)
  * Ubuntu 18.04 LTS or 20.04 LTS
  * CentOS/RHEL 7/8 64 bit preferable

`Sorry I have no time to check Debian and Suse.`   

+ Packages:
  * vagrant 2.2.10 or higher (https://www.vagrantup.com/intro/getting-started/install.html)
  * python 2.8 or higher (https://www.python.org/download/releases/2.7/)
  * git 1.8 or higher for Linux / 2.29.2 or higher for Windows  (https://pl.atlassian.com/git/tutorials/install-git)
  * VirtualBox 6.1 or higher (https://www.virtualbox.org/wiki/Downloads)
  <!--- is not needed anymore cause I'm using ansible_local
  * Ansible 2.8 or higher (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
  --->

When your operating system is Windows please consider Cygwin installation. You have always alternative to install WSL1 or 2.

## Before you start
Please install all extensions for libvirt avoiding dependency module installation
failure!

### Installing VirtualBox
From your laptop/desktop if you have 

CentOS 7.X/RHEL 7.X, CentOS 8.X/RHEL 8.X or Windows go through documentation. This topic goes beyound scope of this article!

Windows: https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1.16-140961-Win.exe
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


`<YOUR DISTRIBUTION>`: is just output grabbed from previous list command for example: Ubuntu-20.04

I highly encurage you to use Ubuntu 20.04 LTS!

## Items

+ Host entries:

```
172.16.0.2   k8s-master1
172.16.0.3   k8s-master2
172.16.0.20  k8s-worker1
172.16.0.21  k8s-worker2
172.16.0.22  k8s-worker2
172.16.0.10  k8s-lb
```

`Don't need to be added to your /etc/hosts, in all cases we will use vagrant ssh command instead of standard ssh!`

+ Pods networking
```
Weavenet Networks
```

+ Kubernetes version
```
Kubernetes v1.18.6
```

+ Docker version
```
Docker version 19.03.12, build 48a66213fe
```

+ Operating system version
```
CentOS Linux release 7.8.2003 (Core)
```
+ Vagrant version
```
Vagrant 2.2.9
```

+ Vagrant Image:
```
v2004.01
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

Then you shoud see following dir structure:

```

```

## Start vagrant machines
When repo will be on your station then you need to run only 1 command namely:
You should be in kubernetes-vagrant directory. If not please enter this directory:

We can divide vagrant lab in two section: K8S and CEPH. If you need Persistent storage
based on CEPH you can provision also ceph boxes.

run:

Run provisioning scripts in three waves

***k8s-lb:**
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
Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'k8s-worker1' up with 'virtualbox' provider...
Bringing machine 'k8s-worker2' up with 'virtualbox' provider...
==> k8s-master: Importing base box 'centos/7'...
==> k8s-master: Matching MAC address for NAT networking...
==> k8s-master: Checking if box 'centos/7' version '2004.01' is up to date...
==> k8s-master: Setting the name of the VM: master
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: hostonly
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
.
..
...
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: /tmp/vagrant-shell20200731-28936-1dpyuar.sh
    k8s-master: .--- k8s lab ---.
    k8s-master: |  Master Node  |
    k8s-master: '---------------'
==> k8s-master: Running provisioner: ansible...
    k8s-master: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [k8s-master]

TASK [bootstrap-master : Configure Kubernetes repository] **********************
changed: [k8s-master]

TASK [bootstrap-master : Install kubernetes binaries] **************************
changed: [k8s-master]

TASK [bootstrap-master : Install Epel for further ansible installation] ********
changed: [k8s-master]

TASK [bootstrap-master : Install ansible on master node] ***********************
.
..
...
TASK [push-join : debug] *******************************************************
ok: [k8s-worker2] => {
    "msg": "[preflight] Running pre-flight checks\n[preflight] Reading configuration from the cluster...\n[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'\n[kubelet-start] Downloading configuration for the kubelet from the \"kubelet-config-1.18\" ConfigMap in the kube-system namespace\n[kubelet-start] Writing kubelet configuration to file \"/var/lib/kubelet/config.yaml\"\n[kubelet-start] Writing kubelet environment file with flags to file \"/var/lib/kubelet/kubeadm-flags.env\"\n[kubelet-start] Starting the kubelet\n[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...\n\nThis node has joined the cluster:\n* Certificate signing request was sent to apiserver and a response was received.\n* The Kubelet was informed of the new secure connection details.\n\nRun 'kubectl get nodes' on the control-plane to see this node join the cluster."
}

TASK [push-join : debug] *******************************************************
ok: [k8s-worker2] => {
    "msg": "W0731 10:34:43.065611    6219 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.\n\t[WARNING IsDockerSystemdCheck]: detected \"cgroupfs\" as the Docker cgroup driver. The recommended driver is \"systemd\". Please follow the guide at https://kubernetes.io/docs/setup/cri/"
}

PLAY RECAP *********************************************************************
k8s-worker2                    : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

It can take a while, up to 10 mins. Please be patient.

Alternatively if you prefere you can just do it in one shoot:
```
./setup.sh -aB
```

## Verification
From directory where Vagrantfile is located (kubernetes-vagrant) try connect to k8s-master and k8s-worker[1,2,3] 

### Check if machines are up and running
```
./setup -s
```

### Smoke test from 1st master node:

```
vagrant ssh k8s-master1

```

.--- k8s lab ---.
| Master Node 1 |
'---------------'
[vagrant@k8s-master1 ~]$ hostname
k8s-master1


### Test if you can connect use names:

```
# ping -c 1 k8s-master
PING k8s-master (172.16.0.2) 56(84) bytes of data.
64 bytes from master (172.16.0.2): icmp_seq=1 ttl=64 time=0.202 ms

--- k8s-master ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.202/0.202/0.202/0.000 ms

# ping -c 1 k8s-worker1
PING k8s-worker1 (172.16.0.3) 56(84) bytes of data.
64 bytes from k8s-worker1 (172.16.0.3): icmp_seq=1 ttl=64 time=0.256 ms

--- k8s-worker1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.256/0.256/0.256/0.000 ms

$ ping -c 1 k8s-worker2
PING k8s-worker2 (172.16.0.4) 56(84) bytes of data.
64 bytes from k8s-worker2 (172.16.0.4): icmp_seq=1 ttl=64 time=0.256 ms

--- k8s-worker2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.256/0.256/0.256/0.000 ms

$ ping -c 1 k8s-worker3
PING k8s-worker3 (172.16.0.5) 56(84) bytes of data.
64 bytes from k8s-worker3 (172.16.0.5): icmp_seq=1 ttl=64 time=0.256 ms

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

Please repeat this operation for k8s-worker1 and k8s-worker2 and try to ping each hosts in
k8s cluster.

### List Kubernetes nodes
Kubectl binary has been installed only on master node. If you would like to use kubectl on your station you should install
it and copy configuration from .kubectl directory. Without kubectl you will be not able to check kubernetes status and
other cluster things.

On the master node: "k8s-master" and vagrant user type:

```
kubectl get nodes
```

Then following output should be displayed:

```
NAME          STATUS   ROLES    AGE     VERSION
k8s-master1   Ready    master   16m     v1.18.6
k8s-master2   Ready    master   16m     v1.18.6
k8s-worker1   Ready    <none>   10m     v1.18.6
k8s-worker2   Ready    <none>   4m36s   v1.18.6
k8s-worker3   Ready    <none>   4m36s   v1.18.6

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
default           Active   17m
kube-node-lease   Active   17m
kube-public       Active   17m
kube-system       Active   17m
```


Pods in kube-system namespace:
```
kubectl --namespace kube-system get pods
```

You should see following output:

```
NAME                                       READY   STATUS    RESTARTS   AGE

PLEASE FIX IT WEAVENET INSTEAD CALICO

coredns-66bff467f8-cmr7t                   1/1     Running   0          17m
coredns-66bff467f8-klsw5                   1/1     Running   0          17m
etcd-master                                1/1     Running   0          17m
kube-apiserver-master                      1/1     Running   0          17m
kube-controller-manager-master             1/1     Running   0          17m
kube-proxy-cdhg8                           1/1     Running   0          17m
kube-proxy-hfmz7                           1/1     Running   0          11m
kube-proxy-wfdpr                           1/1     Running   0          5m11s
kube-scheduler-master                      1/1     Running   0          17m

```

Deployments in kube-system namespace:
```
kubectl --namespace kube-system get deployments
```

Desired output:

```
PLEASE FIX IT WEAVENET INSTEAD CALICO
coredns                   2/2     2            2           17m
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

More details about manage processes using powershell you can find under blow link:

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-process?view=powershell-7.1

Thank you!

### To Do
- [ ] Spin up ceph cluster using rook
- [ ] Add Ingress controller traefik as default controller
- [ ] Setup frontend based on flask for course presentation
- [ ] Correct output of commands
- [ ] Provision 2nd master node and rename k8s-master to k8s-master1
- [x] Provision HAProxy loadbalancer correspond to 2 master nodes k8s-master1 and k8s-master2
- [x] One hadshoot provisioner script
- [x] Add apps directory synchronization to each of cluster node
- [x] Replace Ansible on vagrant host using anslible_local on each vagrant vm (PARTIALY DONE)
- [x] Reduce unnecessary steps for disk creation. Extra storage need to be provide only for workers vms