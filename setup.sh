#!/bin/bash
# Who:           When:         What:  
# Janusz Kujawa  06/01/2021    Initialize script

# Variables
master_num=1        # master init number
master_count=2      # master count  
worker_num=1        # worker init number
worker_count=3      # worker count

function func_prov_master {
  echo "LAB PROVISIONER START - MASTERS"
  vagrant up k8s-master
  echo "========END PROVISIONER========"
}

function func_prov_worker {
  echo "LAB PROVISIONER START - WORKER"
  while [ $worker_num -le $worker_count ]
  do
    echo ">>> START PROVISION k8s-worker$worker_num <<<"
    vagrant up k8s-worker$worker_num
    worker_num=$(( $worker_num + 1 ))
  done
  echo "========END PROVISIONER========"
}

# Provision masters and workers
#func_prov_master()
func_prov_worker