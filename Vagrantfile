# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
ST_DIR = ENV.fetch('ST_DIR', 'extrastorage')
CONTROLLER = ENV.fetch('CONTROLLER', 'IDE')

# Variables
IMAGE_NAME_K8S  = "centos/7"
DISK_SIZE = 10240

lab = {
  "k8s-master"  => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.2",   :cpus => 2,  :mem =>2048, :custom_host => "k8s-master.sh",  :ssh_port => "2222" },
  "k8s-worker1" => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.3",   :cpus => 2,  :mem =>1500, :custom_host => "k8s-worker1.sh", :ssh_port => "2223" },
  "k8s-worker2" => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.4",   :cpus => 2,  :mem =>1500, :custom_host => "k8s-worker2.sh", :ssh_port => "2224" },
  "k8s-worker3" => { :osimage => IMAGE_NAME_K8S,  :ip => "172.16.0.5",   :cpus => 2,  :mem =>1500, :custom_host => "k8s-worker3.sh", :ssh_port => "2225" }
  }

system('rm -rf ssh-keys')
system('src/scripts/local/make-ssh-key.sh')

# If does not exist create extra storage dir directory - ceph
FileUtils.mkdir_p "./#{ST_DIR}"

Vagrant.configure("2") do |config|
  lab.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|

      # Disable syncing vagrant directory
      config.vm.synced_folder '.', '/vagrant', disabled: true

      # Setup timezone
      cfg.vm.provision "shell", inline: "timedatectl set-timezone Europe/Warsaw", privileged: true

      # Allow login ssh use password also
      cfg.vm.provision "shell", inline: "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;systemctl restart sshd", privileged: true

      # Define motd
      cfg.vm.provision "shell", path: "src/scripts/provisioning/#{info[:custom_host]}"

      # Propagate ssh keys in case of further ansible usage
      cfg.vm.provision :ansible do |ansible|
        ansible.playbook = "ansible/ssh-key.yaml"
      end # end ssh key propagation

      if (hostname == 'k8s-master') or (hostname == 'k8s-worker1') or (hostname == 'k8s-worker2') or (hostname == 'k8s-worker3') then
        # Prerequisite ansible playbooks for kubernetes
        cfg.vm.provision "ansible" do |ansible|
            ansible.playbook = "ansible/k8s-prereq.yaml"
        end # Kubernetes end ansible playbook runs
      end

      if (hostname == 'k8s-master') then
        
        # k8s bootstrapping master
        cfg.vm.provision :ansible do |ansible|
          ansible.playbook = "ansible/k8s-bootstrap-master.yaml"
        end # end master bootstrapping

        # Download join.sh script from master previously generated
        cfg.vm.provision :ansible do |ansible|
          ansible.playbook = "ansible/k8s-pull-join.yaml"
        end # end pull join.sh from master
      end

      if (hostname == 'k8s-worker1') or (hostname == 'k8s-worker2') or (hostname == 'k8s-worker3') then
        # k8s bootstrapping worker
        cfg.vm.provision :ansible do |ansible|
          ansible.playbook = "ansible/k8s-bootstrap-worker.yaml"
        end # end worker bottstrapping

        # Push join.sh to worker and running joining
        cfg.vm.provision :ansible do |ansible|
          ansible.playbook = "ansible/k8s-push-join.yaml"
        end # end joining worker node to k8s cluster
      end # End host selection

      # start first run privider
      cfg.vm.provider :virtualbox do |vb, override|
        
        # Adding extra disk
        disk = "#{ST_DIR}" + '/' + hostname + '.vmdk'
        if !File.exist?(disk)
           vb.customize ['createhd', '--filename', disk, '--size', "#{DISK_SIZE}", '--variant', 'Fixed']
           vb.customize ['modifyhd', disk, '--type', 'writethrough']
        end
        vb.customize ['storageattach', :id, '--storagectl', CONTROLLER, '--port', 0, '--device', 1, '--type', 'hdd', '--medium', disk] 

        # Memory, CPU, Image configuration
        vb.memory = "#{info[:mem]}"
        vb.cpus = "#{info[:cpus]}"
        config.vm.box = info[:osimage]

        # Configure network and port forwarding  
        #config.vm.network :forwarded_port, guest: 22, host: "#{info[:ssh_port]}" , id: "ssh"
        override.vm.network :private_network, ip: "#{info[:ip]}"

        # Configure hostname
        override.vm.hostname = hostname

      end # end provider
    end # end config
  end # end lab
end
