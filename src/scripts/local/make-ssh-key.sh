#!/bin/bash
mkdir -p ansible/ssh-keys
ssh-keygen -t rsa -b 4096 -f ansible/ssh-keys/k8s-cluster -q -N ""
