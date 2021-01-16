#!/bin/bash
# Who:              When:          What:
# Janusz Kujawa     06/01/2021     Script initialization
# Janusz Kujawa     16/01/2021     Added variables instead of full path of dirs
#                                  $SSH_KEY_DIR.

SSH_KEY_DIR="ansible/ssh-keys"
K8S_PRIV_KEY_FILE="k8s-cluster"
K8S_PUB_KEY_FILE="k8s-cluster.pub"

if [ ! -d $SSH_KEY_DIR ] | [ -z "$(ls -A $SSH_KEY_DIR)" ] ; then 
  echo "SSH directory not found or is empty creating..."
  mkdir -p $SSH_KEY_DIR
  if [ ! -f $K8S_PRIV_KEY_FILE ] | [ ! -f $K8S_PUB_KEY_FILE ] ; then
    echo "SSH keys not found creating them..."
    ssh-keygen -t rsa -b 4096 -f $SSH_KEY_DIR'/'$K8S_PRIV_KEY_FILE -q -N ""
    echo "----------------------------------------"
    echo "Following files have been generated:"
    find "$SSH_KEY_DIR" -type f
  else
    echo "SSH keys found generation not needed"
  fi
else
  echo "SSH directory found or contains ssh keys generation stopped!"
fi