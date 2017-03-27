#!/bin/bash
# Set Environment Variables
COUNT=4
REPO="some_repo_url_without_the_http"
IMAGE="rhel-guest-image-7.2-20151102.0.x86_64.qcow2"
DYREPOCFG="/etc/yum.repos.d/osp8.repo"
DIMG="/home/stack/$IMAGE"
DIST="rhel7"

# SET SHELL VARS #
setshv() {
    export DIB_LOCAL_IMAGE=$DIMG
    export DIB_YUM_REPO_CONF=$DYREPOCFG
    export NODE_COUNT=$COUNT
    export NODE_DIST=$DIST
}

## REMOVE ALL VMs ##
rminstk() {
    for i in instack baremetalbrbm_0 baremetalbrbm_1 baremetalbrbm_2 baremetalbrbm_3; do sudo virsh destroy $i; sudo virsh undefine $i; done
    sudo rm -rf /home/images/*
}

## REMOVE IMAGES ##
rmimage() {
    sudo rm -rf instack.qcow2 instack.d/ instack*qcow2 $IMAGE .cache/ .instack/
}

## ... ##
getimg() {
    wget http://$REPO/images/$IMAGE
}

## INSTACK SETUP ##
instack() {
    instack-virt-setup
}

## Set the following parameters for Memory/vCPU/etc.
## Instack Memory Total: 12GB
## Controllers: 8GB /ea
## Compute: 5GB / ea
## Include vCPUs, attach overclouds to addt'l networks for isolation/etc..

cfg_instack() {
    sudo virsh destroy instack
    sudo virt-xml instack --edit --memory 12000,maxmemory=12000
    sudo virt-xml instack --edit --vcpu 4
    sudo virsh start instack
}

cfg_brbm() {
    sudo ifconfig brbm 192.0.2.250 netmask 255.255.255.0
    sudo virt-xml baremetalbrbm_0 --edit --memory 8000,maxmemory=8000
    sudo virsh attach-interface --domain baremetalbrbm_0 --type bridge --source vswitch --model virtio --config; sudo virt-xml baremetalbrbm_0 --edit 2  --network virtualport_type=openvswitch
    sudo virsh attach-interface --domain baremetalbrbm_0 --type bridge --source provider --model virtio --config; sudo virt-xml baremetalbrbm_0 --edit 3  --network virtualport_type=openvswitch
    sudo virt-xml baremetalbrbm_0 --edit --vcpu 4
    sudo virt-xml baremetalbrbm_1 --edit --memory 8000,maxmemory=8000
    sudo virsh attach-interface --domain baremetalbrbm_1 --type bridge --source vswitch --model virtio --config; sudo virt-xml baremetalbrbm_1 --edit 2  --network virtualport_type=openvswitch
    sudo virsh attach-interface --domain baremetalbrbm_1 --type bridge --source provider --model virtio --config; sudo virt-xml baremetalbrbm_1 --edit 3  --network virtualport_type=openvswitch
    sudo virt-xml baremetalbrbm_1 --edit --vcpu 4
    sudo virt-xml baremetalbrbm_2 --edit --memory 8000,maxmemory=8000
    sudo virsh attach-interface --domain baremetalbrbm_2 --type bridge --source vswitch --model virtio --config; sudo virt-xml baremetalbrbm_2 --edit 2  --network virtualport_type=openvswitch
    sudo virsh attach-interface --domain baremetalbrbm_3 --type bridge --source provider --model virtio --config; sudo virt-xml baremetalbrbm_2 --edit 3  --network virtualport_type=openvswitch
    sudo virt-xml baremetalbrbm_2 --edit --vcpu 4
    sudo virt-xml baremetalbrbm_3 --edit --memory 5000,maxmemory=5000
    sudo virsh attach-interface --domain baremetalbrbm_3 --type bridge --source vswitch --model virtio --config; sudo virt-xml baremetalbrbm_3 --edit 2  --network virtualport_type=openvswitch
    sudo virsh attach-interface --domain baremetalbrbm_3 --type bridge --source provider --model virtio --config; sudo virt-xml baremetalbrbm_3 --edit 3  --network virtualport_type=openvswitch
    sudo virt-xml baremetalbrbm_3 --edit --vcpu 4
    sleep 20
}

## COPY TO UNDERCLOUD: THIS STEP FAILS ##
cptoUC() {
    undercloud_ip=$(grep -B2 'hostname": "instack' /var/lib/libvirt/dnsmasq/virbr0.status  | grep ip-address | cut -f4 -d\" | tail -n1 )
    scp -o StrictHostKeyChecking=no deploy-overcloud.sh templates.tar.bz2 root@$undercloud_ip:/home/stack/
}

setshv
rminstk
rmimage
getimg
instack
cfg_instack
cfg_brbm
cptoUC
