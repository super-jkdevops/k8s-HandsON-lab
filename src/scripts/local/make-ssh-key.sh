#!/bin/bash
# Who:              When:          What:
# Janusz Kujawa     06/01/2021     Script initialization
SSH_KEY_DIR="ansible/ssh-keys"
K8S_PRIV_KEY_FILE="k8s-cluster"
K8S_PUB_KEY_FILE="k8s-cluster.pub"

if [ ! -d ansible/ssh-keys ] | [ -n "$(find "$SSH_KEY_DIR" -maxdepth 0 -type d -empty 2>/dev/null)" ] ; then
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