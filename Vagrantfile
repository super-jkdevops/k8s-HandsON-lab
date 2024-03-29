# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
ENV['VAGRANT_NO_PARALLEL'] = 'yes'
CONTROLLER = ENV.fetch('CONTROLLER1', 'VirtIO')
ST_DIR = "extradisks/"

# Variables
#IMAGE_NAME_K8S  = "centos/7"
IMAGE_NAME_K8S  = "bento/ubuntu-18.04"
IMAGE_NAME_LB = "bento/ubuntu-18.04"
DISK1_SIZE = 10240
DISK2_SIZE = 20480
PLAYBOOK_DIR = "/vagrant/ansible"
ROLES_DIR = "/vagrant/ansible/roles"
ANSIBLE_INVENTORY = "#{PLAYBOOK_DIR}" + '/inventory/hosts'

# Generate ssh keys for K8S further usage
system("
    if [ #{ARGV[0]} = 'up' ]; then
        echo '!!! You are trying to spin up k8s Lab system starting generate ssh key for further use !!!'
        src/scripts/local/make-ssh-key.sh
    fi
")

lab = {
  "k8s-lb"      => { :osimage => IMAGE_NAME_LB,   :ip => "172.16.0.10", :cpus => 1,  :mem =>512,   :custom_host => "k8s-lb.sh"      },
  "k8s-master1" => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.2",  :cpus => 2,  :mem =>1500,  :custom_host => "k8s-master1.sh" },
  "k8s-master2" => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.3",  :cpus => 2,  :mem =>1500,  :custom_host => "k8s-master2.sh" },
  "k8s-master3" => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.4",  :cpus => 2,  :mem =>1500,  :custom_host => "k8s-master3.sh" },
  "k8s-worker1" => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.20", :cpus => 6,  :mem =>2500,  :custom_host => "k8s-worker1.sh" },
  "k8s-worker2" => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.21", :cpus => 6,  :mem =>2500,  :custom_host => "k8s-worker2.sh" },
  "k8s-worker3" => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.22", :cpus => 6,  :mem =>2500,  :custom_host => "k8s-worker3.sh" }
  }

# If does not exist create extra storage dir directory - ceph
FileUtils.mkdir_p "./#{ST_DIR}"

Vagrant.configure("2") do |config|
  lab.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|

      # Synchronization apps/ dir into destination /vagrant dir (needed for deploy application into K8s cluster)
      config.vm.synced_folder '.', '/vagrant',
      type: 'rsync',
      # rsync__verbose: true,
      rsync__exclude: [
        'extrastorage', '.gitignore',
        'README.md', 'Vagrantfile', '.vagrant', 
        '.git', 'setup.sh',
      ]
      
      # Setup timezone
      cfg.vm.provision "shell", inline: "timedatectl set-timezone Europe/Warsaw", privileged: true

      # Allow login ssh use password also
      cfg.vm.provision "shell", inline: "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;systemctl restart sshd", privileged: true

      # Define motd
      cfg.vm.provision "shell", path: "src/scripts/provisioning/#{info[:custom_host]}", privileged: true

      # Propagate ssh keys in case of further ansible usage
      cfg.vm.provision "ansible_local" do |ansible|
        ansible.verbose = true
        ansible.install = true
        ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'ssh-key.yaml'
        ansible.galaxy_roles_path = "#{ROLES_DIR}"
      end # end ssh key propagation

      # Prepare /etc/hosts adopt entries interconnect cluster
      cfg.vm.provision "ansible_local" do |ansible|
        ansible.verbose = true
        ansible.install = true
        ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-hosts.yaml'
        ansible.galaxy_roles_path = "#{ROLES_DIR}"
      end # end hosts file preparation

      if (hostname == 'k8s-lb') then

        # k8s loadbalancer spinup
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-lb-provision.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # end installing loadbalancer

      end # End host selection

      if (hostname == 'k8s-master1') or (hostname == 'k8s-master2')or (hostname == 'k8s-master3') or (hostname == 'k8s-worker1') or (hostname == 'k8s-worker2') or (hostname == 'k8s-worker3') then
        # Prerequisite ansible playbooks for kubernetes
        cfg.vm.provision "ansible_local" do |ansible|
            ansible.verbose = "v"
            ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-prereq.yaml'
            ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # Kubernetes end ansible playbook runs
      end

      # Initialize first control plane and give possibility to upload keys
      if (hostname == 'k8s-master1') then
        # k8s bootstrapping master
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-bootstrap-master-1st.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # end master bootstrapping
      end

      # Join more masters as need redundancy control plane
      if (hostname == 'k8s-master2') or (hostname == 'k8s-master3') then
        
        # Download join script from master previously generated - control plane functionality
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-pull-join-master.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
          ansible.inventory_path = "#{ANSIBLE_INVENTORY}"
          ansible.limit = "k8s-master1"
        end # end pull join.sh from master
        
        # k8s bootstrapping rest of masters
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-bootstrap-master-rest.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # end master bootstrapping
      end

      # Join more masters as need redundancy control plane
      if (hostname == 'k8s-lb') then
        # Download kubeconfig from 1st master node
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-download-kubeconfig.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
          ansible.inventory_path = "#{ANSIBLE_INVENTORY}"
          ansible.limit = "k8s-master1"
        end # end downloading kubeconfig
        
        # k8s bootstrapping rest of masters
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-bootstrap-master-rest.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # end master bootstrapping
      end

      if (hostname == 'k8s-worker1') or (hostname == 'k8s-worker2') or (hostname == 'k8s-worker3') then

        cfg.vm.provider :virtualbox do |vb, override|

          # Add VirtIO controller
          vb.customize ["storagectl", :id, "--name", CONTROLLER, "--add", "virtio-scsi" ]
       
          # Adding extra disk to all worker nodes
          #file_disk1 = "#{ST_DIR}" + '/' + hostname + '_disk1.vdi'
          file_disk1 = ST_DIR + hostname + '_disk1.vdi'
          file_disk2 = ST_DIR + hostname + '_disk2.vdi'

          unless File.exist?(file_disk1)
            vb.customize ['createhd', '--filename', file_disk1, '--size', "#{DISK1_SIZE}"]
          end

          unless File.exist?(file_disk2)
            vb.customize ['createhd', '--filename', file_disk2, '--size', "#{DISK1_SIZE}"]
          end
         
          # Attach disk to vm
          vb.customize ['storageattach', :id, '--storagectl', CONTROLLER, '--port', 0, '--device', 0, '--type', 'hdd', '--medium', file_disk1 ]
          vb.customize ['storageattach', :id, '--storagectl', CONTROLLER, '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_disk2 ]

        end # end provider
      

        # Download join script from master previously generated - compute functionality
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-pull-join-worker.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
          ansible.inventory_path = "#{ANSIBLE_INVENTORY}"
          ansible.limit = "k8s-master1"
        end # end pull join.sh from master

        # k8s bootstrapping worker
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-bootstrap-worker.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # end worker bottstrapping

        # k8s join worker
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-join-worker.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # end worker joining

      end # End host selection

      # start first run privider
      cfg.vm.provider :virtualbox do |vb, override|

        # Memory, CPU, Image configuration
        vb.memory = "#{info[:mem]}"
        vb.cpus = "#{info[:cpus]}"
        config.vm.box = info[:osimage]

        override.vm.network :private_network, ip: "#{info[:ip]}"

        # Configure hostname
        override.vm.hostname = hostname

      end # end provider
    end # end config
  end # end lab
end
