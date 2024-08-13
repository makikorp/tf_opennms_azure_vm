



This repo creates an instance of OpenNMS in azure running on Rocky 9 Linux using Terraform and Ansible

An Azure account is required.

Please note that there are 2 options in the Ansible playbook for OpenNMS.  Option 1) is deploying Horizon, Option 2) is deploying Meridian.

To deploy Horizon please ensure the following are uncommented in the playbook opennms.yml:


    # USE BELOW FOR HORIZON
    - name: add opennms to yum repo
      ansible.builtin.shell:
        cmd: sudo yum -y install https://yum.opennms.org/repofiles/opennms-repo-stable-rhel9.noarch.rpm

    - name: Update yum cache and install opennms
      ansible.builtin.yum: 
        name: opennms
        # name: meridian
        state: present
        update_cache: yes
        disable_gpg_check: yes

Additionally, to deploy Horizon please comment out the section in the Ansible playbook for meridian.repo:

    #USE BELOW FOR MERIDIAN
    #- name: cp meridian.repo  
    #  copy:
    #    src: /Users/emaki/code/tf_opennms_azure_vm/meridian.repo
    #    dest: /etc/yum.repos.d/
    #    owner: eric
    #    mode: 0755   

*****

To deploy Meridian please ensure the following are uncommented in the playbook opennms.yml:

Please uncomment the section:

    #USE BELOW FOR MERIDIAN
    - name: cp meridian.repo  
      copy:
        src: /Users/emaki/code/tf_opennms_azure_vm/meridian.repo
        dest: /etc/yum.repos.d/
        owner: eric
        mode: 0755   


In the file meridian.repo, please replace REPO_USER and REPO_PASS with your credentials.  You can also change "2024" to another version ie 2022 or 2023. 
baseurl=https://REPO_USER:REPO_PASS@meridian.opennms.com/packages/2024/stable/rhel9


Please comment out the following section in the Ansible playbook:

    # USE BELOW FOR HORIZON
    #- name: add opennms to yum repo
    #  ansible.builtin.shell:
    #    cmd: sudo yum -y install https://yum.opennms.org/repofiles/opennms-repo-stable-rhel9.noarch.rpm

    - name: Update yum cache and install opennms
      ansible.builtin.yum: 
        #name: opennms
        name: meridian
        state: present
        update_cache: yes
        disable_gpg_check: yes

The file "azure_hosts" is for the Ansible playbook to know the ip address of the azure vm to run the playbook against.

If Ansible does not connect, please run the ansible command directly on the command line:
ansible-playbook -i /users/<user>/code/tf_opennms_azure_vm/azure_hosts --key-file /Users/<user>/.ssh/<user_key> playbooks/opennms.yml

