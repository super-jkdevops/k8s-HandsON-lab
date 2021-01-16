#!/bin/bash
# Who:           When:         What:  
# Janusz Kujawa  06/01/2021    Initialize script
# Janusz Kujawa  08/01/2021    Added loadbalancer function for provision LB based on HAProxy
# Janusz Kujawa  16/01/2021    Added case for lack of arguments and option

# Variables
master_num=1        # master init number
master_count=3      # master count  
worker_num=1        # worker init number
worker_count=3      # worker count

usage() {                                     
   echo
   echo "Syntax: $0  [-h|a|d|m|w|s]"
   echo "options:"
   echo "h          Print help available options"
   echo "a          Start whole k8s HandsON LAB"
   echo "d          Destroy k8s HandsON LAB"
   echo "m          Start k8s HandsON LAB masters only"
   echo "l          Start k8s HandsON LAB loadbalancer only"
   echo "w          Start k8s HandsON LAB workers only"
   echo "s          Print k8s HandsON LAB status"
   echo
   exit 0
}

no_option() {                            
  usage
  exit 1
}

function func_prov_master {
  echo ">>> LAB PROVISIONER START - MASTERS <<<"
  while [ $master_num -le $master_count ]
  do
    echo ">>> START PROVISION k8s-master$master_num <<<"
    vagrant up k8s-master$master_num
    master_num=$(( $master_num + 1 ))
  done
  echo "========END PROVISIONER========"
}

function func_prov_worker {
  echo ">>> LAB PROVISIONER START - WORKER <<<"
  while [ $worker_num -le $worker_count ]
  do
    echo ">>> START PROVISION k8s-worker$worker_num <<<"
    vagrant up k8s-worker$worker_num
    worker_num=$(( $worker_num + 1 ))
  done
  echo "========END PROVISIONER========"
}

function func_prov_loadbalancer {
  echo ">>> LAB PROVISIONER START - LOADBALANCER <<<"
  vagrant up k8s-lb
  echo "========END PROVISIONER========"
}

function func_destroy {
  echo ">>> LAB PROVISIONER DESTROY K8S CLUSTER <<<"
  vagrant destroy -f
  echo "========END PROVISIONER========"
}

function func_status {
  echo ">>> LAB PROVISIONER STATUS K8S CLUSTER <<<"
  vagrant status
  echo "========END PROVISIONER========"
}

if [[ $# -eq 0 ]] ; then
    echo "!!! No argument and option given !!!"
    no_option
    exit 0
fi

while getopts "hadmlws" options; do            
                                                                                        
  case $options in                          
    h)
      usage                                        
      ;;
    a)
      func_prov_loadbalancer
      func_prov_master
      func_prov_worker
      ;;
    d)
      func_destroy
      ;;
    m)
      func_prov_master
      ;;
    l)
      func_prov_loadbalancer
      ;;
    w) 
      func_prov_worker
      ;;
    s) 
      func_status
      ;;
    *)                                        
      no_option                           
      ;;
  esac
done



