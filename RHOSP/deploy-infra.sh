#!/bin/bash
# Deploy Infra Script: based on spithuen 
#
#-------- Start VARS --------#
# User Definition:
USER="stack"
PASS="password"

# Foundation setup and config settings:
REPO_SERVER="somerepo_url_sans_the_http_part"
COUNT=4
IMAGE="rhel-guest-image-7.2-20151102.0.x86_64.qcow2"

# There are two package sets, the first one is used for FFox / X11 / VNC etc.. The second one is just cli tools.
PACKAGES="screen virt-manager dejavu-sans-fonts firefox xorg-x11-xauth instack-undercloud openvswitch net-tools virt-install libvirt libguestfs-tools-c nfs-utils tigervnc-server telnet screen nfs wget vim-enhanced"

# Memory Settings for Virsh:
MEM="12000"
MAXMEM="12000"
# CPU Settings for Virsh:
VCPU="4"

#-------- END VARS --------#

# Create stack user with password password
users() {
    useradd $USER
    echo "$PASS" | passwd stack --stdin
    echo "$USER ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
    chmod 0440 /etc/sudoers.d/stack
    cp /root/deploy-infra.sh /home/stack/
    chown stack:stack /home/stack/deploy-infra.sh
    clear && clear
    echo "***************************************"
    echo "** Now Performing 'su -l stack' Once **"
    echo "** loged in as stack re-run deploy-  **"
    echo "** infra.sh and let it run...        **"
    echo "** Suggest using screen so you can   **"
    echo "** walk away and let it run.......   **"
    echo "***************************************"
    su -l stack
}

# Setup the repos
fetch() {
    curl http://$REPO_SERVER/osp9.repo > osp9.repo
    sudo mv osp9.repo /etc/yum.repos.d/
}

# Stop NM and Disable
nmdisable() {
    sudo systemctl stop NetworkManager
    sudo systemctl disable NetworkManager
}

# Import the GPG and install stuff and things.
keyinstall() {
    sudo rpm --import /etc/pki/rpm-gpg/*
    sudo rm -rf /var/cache/yum/*
    sudo yum clean all
    sudo yum install -y $PACKAGES
    sudo systemctl restart {libvirtd,openvswitch}
    sudo systemctl enable {libvirtd,openvswitch,nfs-server.service}
    sudo systemctl start nfs-server.service
}

# Get QCOW2 IMAGE and link things:
IMAGElink() {
    sudo wget -O ~stack/$IMAGE http://$REPO_SERVER/images/$IMAGE
    sudo rm -rf /var/lib/libvirt/images
    sudo mkdir /home/images
    sudo ln -s /home/images /var/lib/libvirt/images
}

# Setup the NFS Shares for glance and cinder. For NON-CEPH installs.
nfs() {
    sudo mkdir /home/{glance,cinder}
    sudo chmod 777 /home/{glance,cinder}
    echo "/home/cinder  *(rw,sync)" >> exports
    echo "/home/glance  *(rw,sync)" >> exports
    sudo /bin/cp exports /etc
    sudo exportfs -avr
    sudo chown 165 /home/cinder/
    sudo chown 161 /home/glance/
}

# Disable SE Linux:
sedisable() {
    sudo setenforce 0
}

# Create ovs bridge, vswitch, add ports for the networks:
networking() {
    sudo ovs-vsctl add-br vswitch
    sudo ovs-vsctl add-port vswitch external tag=10 -- set Interface external type=internal
    sudo ovs-vsctl add-port vswitch storage tag=20 -- set Interface storage type=internal
    sudo ovs-vsctl add-port vswitch api tag=30 -- set Interface api type=internal
    sudo ovs-vsctl add-port vswitch storage_mgmt tag=40 -- set Interface storage_mgmt type=internal
    sudo ovs-vsctl add-port vswitch tenant tag=50 -- set Interface tenant type=internal
    sudo ovs-vsctl add-br provider
    for i in `seq 1 5`
      do
        sudo ovs-vsctl add-port provider provider-port$i tag=10$i -- set Interface provider-port$i type=internal
        sudo ifconfig provider-port$i 172.1.$i.254 netmask 255.255.255.0
      done
}

# These should be modified depending.
# Long term plan add function to request various IP info
# and turn it into $variables. For instance $EXTERNAL='input from user'
netcfgs() {
    sudo iptables -F
    sudo ifconfig external 10.11.48.254/24
    sudo ifconfig api 192.168.124.254/24
    sudo ifconfig tenant 192.168.123.254/24
    sudo ifconfig storage_mgmt 192.168.128.254/24
    sudo ifconfig storage 192.168.125.254/24
    sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sudo sysctl -p
}

# Setup environmental variables
exports() {
    export DIB_LOCAL_IMAGE=/home/stack/$IMAGE
    export DIB_YUM_REPO_CONF=/etc/yum.repos.d/osp9.repo
    export NODE_COUNT=$COUNT
    export NODE_DIST=rhel7
    instack-virt-setup
}

# Memory and vCPU adjustment for each of the VMs. Attach each VM to additional vSwitch and provider network.
adjmemcpu() {
    sudo virsh destroy instack
    sudo virt-xml instack --edit --memory 12000,maxmemory=12000
    sudo virt-xml instack --edit --vcpu 4
    sudo virsh start instack
}

baremtl0() {
    sudo ifconfig brbm 192.0.2.250 netmask 255.255.255.0
    sudo virt-xml baremetalbrbm_0 --edit --memory 8000,maxmemory=8000
    sudo virsh attach-interface --domain baremetalbrbm_0 --type bridge --source vswitch --model virtio --config; sudo virt-xml baremetalbrbm_0 --edit 2  --network virtualport_type=openvswitch
    sudo virsh attach-interface --domain baremetalbrbm_0 --type bridge --source provider --model virtio --config; sudo virt-xml baremetalbrbm_0 --edit 3  --network virtualport_type=openvswitch
    sudo virt-xml baremetalbrbm_0 --edit --vcpu 4
}

baremtl1() {
    sudo virt-xml baremetalbrbm_1 --edit --memory 8000,maxmemory=8000
    sudo virsh attach-interface --domain baremetalbrbm_1 --type bridge --source vswitch --model virtio --config; sudo virt-xml baremetalbrbm_1 --edit 2  --network virtualport_type=openvswitch
    sudo virsh attach-interface --domain baremetalbrbm_1 --type bridge --source provider --model virtio --config; sudo virt-xml baremetalbrbm_1 --edit 3  --network virtualport_type=openvswitch
    sudo virt-xml baremetalbrbm_1 --edit --vcpu 4
}

baremtl2() {
    sudo virt-xml baremetalbrbm_2 --edit --memory 8000,maxmemory=8000
    sudo virsh attach-interface --domain baremetalbrbm_2 --type bridge --source vswitch --model virtio --config; sudo virt-xml baremetalbrbm_2 --edit 2  --network virtualport_type=openvswitch
    sudo virsh attach-interface --domain baremetalbrbm_2 --type bridge --source provider --model virtio --config; sudo virt-xml baremetalbrbm_2 --edit 3  --network virtualport_type=openvswitch
    sudo virt-xml baremetalbrbm_2 --edit --vcpu 4
}

baremtl3() {
    sudo virt-xml baremetalbrbm_3 --edit --memory 5000,maxmemory=5000
    sudo virsh attach-interface --domain baremetalbrbm_3 --type bridge --source vswitch --model virtio --config; sudo virt-xml baremetalbrbm_3 --edit 2  --network virtualport_type=openvswitch
    sudo virsh attach-interface --domain baremetalbrbm_3 --type bridge --source provider --model virtio --config; sudo virt-xml baremetalbrbm_3 --edit 3  --network virtualport_type=openvswitch
    sudo virt-xml baremetalbrbm_3 --edit --vcpu 4
    sleep 20
}

# Locate the undercloud IP && copy deploy shell and templates to undercloud
ucstart() {
   undercloud_ip=$(grep -B2 'hostname": "instack' /var/lib/libvirt/dnsmasq/virbr0.status  | grep ip-address | cut -f4 -d\" | tail -n1 )
   scp -o StrictHostKeyChecking=no deploy-overcloud.sh templates.tar.bz2 root@undercloud_ip:/home/stack/
}

## Uncomment any or all of the below entries to run them.
#users
#fetch
#nmdisable
#keyinstall
#IMAGElink
#nfs
#sedisable
#networking
#netcfgs
#exports
#adjmemcpu
#baremtl0
#baremtl1
#baremtl2
#baremtl3
#ucstart
