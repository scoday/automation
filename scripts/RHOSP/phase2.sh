#!/usr/bin/bash
# Phase Two:


epel() {
    # Download the latest release of epel this will include instack-undercloud.
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm


}

export NODE_DIST=rhel7
export NODE_CPU=4
export UNDERCLOUD_NODE_CPU=4
export UNDERCLOUD_NODE_MEM=12288
export NODE_MEM=12288
export DIB_LOCAL_IMAGE=rhel-guest-image-7.2.x86_64.qcow2
export REG_METHOD=portal
export REG_USER="rhn-user"
export REG_PASSWORD="password"
export REG_POOL_ID="pool-id"
export REG_REPOS="rhel-7-server-rpms rhel-7-server-extras-rpms rhel-7-server-openstack-8-rpms rhel-7-server-openstack-8-director-rpms rhel-7-server-rh-common-rpms"export NODE_COUNT=5
export LIBVIRT_VOL_POOL=tripleo
export LIBVIRT_VOL_POOL_TARGET=/home/vm_storage_pool
