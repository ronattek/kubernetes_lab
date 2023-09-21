# Kubernets lab

## Summary

This repo is to help with bringing up an on prem lab.  It includes a Vagrant file for ease of testing and reproducing the environment locally.

## Getting Started

1.  Adjust your inventory files as needed for your machines you will be working with.  Keep in mind that these day zero playbooks are designed for ubuntu/debian machines.  Local usage will look something like:
```
ansible-playbook -i inventory.yml playbooks/day_zero.yml -u a_sudo_user -e ansible_ssh_pass=superlamepassword -K
```
2.  (In progress) The cluster init playbook does the following:  Installs kubernetes, generates required csrs, keys, and certs ...(to be continued)

## Vagrant
1.  Install virtualbox and vagrant
2.  Run the following: ```vagrant up```