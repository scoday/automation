#!/usr/bin/bash
#
# Just a script to make the install a bit quicker.
# Things and stuff "Loud Noises."
#------------------------------------------------------
#
PASS = stack


subbscriptions() {
    rhn-user 
    subscription-manager register
    subscription-manager attach --pool=8a85f9833e1404a9013e3cddf95a0599
    subscription-manager repos --disable=*
    subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms\
    --enable=rhel-7-server-openstack-9-rpms --enable=rhel-7-server-openstack-9-director-rpms\
    --enable=rhel-7-server-rh-common-rpms
}

user() {
    useradd stack
    echo "$PASS" | passwd stack --stdin
    echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
    chmod 0440 /etc/sudoers.d/stack
    yum update -y
    clear
    echo "Reboot in ten seconds, ctrl+c to cancel."
    echo "When the box is back up - login and sudo su - stack then run phase2 from stack"
    echo "Sleeping 10."
    sleep 10
}
