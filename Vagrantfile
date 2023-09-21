# -*- mode: ruby -*-
# vi: set ft=ruby :

##############################################################
#                                                            #
# SET YOUR VARS HERE                                         #
#                                                            #
# COMMENT AS NECESSARY, EXAMPLES SHOULD BE OBVIOUS           #
#                                                            #
##############################################################

worker_count = 2 #obviously don't make this too big for your host
master_address= "" # TODO: Store this var outside of the scope of the configuration process, might need to be static
# network_range = ??? # TODO, may be needed for vagrant

Vagrant.configure(2) do |config|

###################################
#                                 #
# MASTER NODE                     #
#                                 #
###################################

    config.vm.define "k8-master01" do |ubuntu|
      ubuntu.vm.hostname = "k8-master.dev"
  
      ubuntu.vm.box = "bento/ubuntu-20.04"
      ubuntu.vm.provider "virtualbox" do |vb|
          vb.memory = 2048
          vb.cpus = 2
      end
    end

    config.vm.provision "ansible_local" do |ansible|
      ansible.extra_vars = {
          k8_host_type: "master",

      }
      ansible.playbook = "playbooks/day_zero.yml"
      ansible.playbook = "playbooks/cluster_init.yml"

    end

###################################
#                                 #
# WORKER NODES                    #
#                                 #
###################################

    (1..worker_count).each do |i|
        config.vm.define "k8-worker0#{i}" do |ubuntu|
            ubuntu.vm.hostname = "k8-worker0#{i}.dev"
        
            ubuntu.vm.box = "bento/ubuntu-20.04"
            ubuntu.vm.provider "virtualbox" do |vb|
                vb.memory = 2048
                vb.cpus = 2
            end
        end
    
        config.vm.provision "ansible_local" do |ansible|
            ansible.extra_vars = {
                k8_host_type: "worker"
            }
            ansible.playbook = "playbooks/day_zero.yml"
            ansible.playbook = "playbooks/cluster_init.yml"
        end
    end

  end