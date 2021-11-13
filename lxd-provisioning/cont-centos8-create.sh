#!/bin/bash
CGROUP_SUFFIX=$1

echo ''
echo "=============================================="
echo "Create k8s-weavenet profile...                "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc profile create k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
eval echo "'cat k8s-profile-config-weavenet | /var/lib/snapd/snap/bin/lxc profile edit k8s-weavenet' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "=============================================="
echo "Done: Create k8s-weavenet profile.            "
echo "=============================================="
echo ''

sleep 5

echo ''
echo "=============================================="
echo "Create maestro LXD container...               "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc launch images:centos/8/amd64 maestro --profile k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
cp ifcfg-eth0-maestro ifcfg-eth0
sleep 5

Status=1
n=1
while [ $Status -ne 0 ] && [ $n -le 5 ]
do
	eval echo "'/var/lib/snapd/snap/bin/lxc file push ifcfg-eth0 maestro/etc/sysconfig/network-scripts/' | sg lxd $CGROUP_SUFFIX"
	Status=`echo $?`
	n=$((n+1))
	sleep 5
done

eval echo "'/var/lib/snapd/snap/bin/lxc stop  maestro' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start maestro' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "=============================================="
echo "Done: Create maestro LXD container.           "
echo "=============================================="
echo ''

sleep 5

echo ''
echo "=============================================="
echo "Create violin1 LXD container...              "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc launch images:centos/8/amd64 violin1 --profile k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
cp ifcfg-eth0-violin1 ifcfg-eth0
sleep 5

Status=1
n=1
while [ $Status -ne 0 ] && [ $n -le 5 ]
do
	eval echo "'/var/lib/snapd/snap/bin/lxc file push ifcfg-eth0 violin1/etc/sysconfig/network-scripts/' | sg lxd $CGROUP_SUFFIX"
	Status=`echo $?`
	n=$((n+1))
	sleep 5
done

eval echo "'/var/lib/snapd/snap/bin/lxc stop  violin1' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start violin1' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "=============================================="
echo "Done: Create violin1 LXD container.          "
echo "=============================================="
echo ''

sleep 5

echo ''
echo "=============================================="
echo "Create violin2 LXD container...              "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc launch images:centos/8/amd64 violin2 --profile k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
cp ifcfg-eth0-violin2 ifcfg-eth0
sleep 5

Status=1
n=1
while [ $Status -ne 0 ] && [ $n -le 5 ]
do
	eval echo "'/var/lib/snapd/snap/bin/lxc file push ifcfg-eth0 violin2/etc/sysconfig/network-scripts/' | sg lxd $CGROUP_SUFFIX"
	Status=`echo $?`
	n=$((n+1))
	sleep 5
done

eval echo "'/var/lib/snapd/snap/bin/lxc stop  violin2' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start violin2' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "=============================================="
echo "Create violin2 LXD container...              "
echo "=============================================="
echo ''

sleep 5

echo ''
echo "=============================================="
echo "Install packages...                           "
echo "=============================================="
echo ''

Status=1
n=1
while [ $Status -ne 0 ] && [ $n -le 5 ]
do
	eval echo "'/var/lib/snapd/snap/bin/lxc exec maestro -- dnf -y install openssh-server net-tools bind-utils git rsync' | sg lxd $CGROUP_SUFFIX"
	Status=`echo $?`
	n=$((n+1))
	sleep 5
done

eval echo "'/var/lib/snapd/snap/bin/lxc exec violin1 -- dnf -y install openssh-server net-tools bind-utils git rsync' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin2 -- dnf -y install openssh-server net-tools bind-utils git rsync' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "=============================================="
echo "Install packages...                           "
echo "=============================================="
echo ''

sleep 5

echo ''
echo "=============================================="
echo "Enables and start sshd ...                    "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc exec maestro --  systemctl enable sshd' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin1 -- systemctl enable sshd' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin2 -- systemctl enable sshd' | sg lxd $CGROUP_SUFFIX"

eval echo "'/var/lib/snapd/snap/bin/lxc exec maestro --  service sshd start' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin1 -- service sshd start' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin2 -- service sshd start' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "=============================================="
echo "Enables and start sshd ...                    "
echo "=============================================="
echo ''

sleep 15

echo ''
echo "=============================================="
echo "Set root password in containers...            "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc exec maestro  -- usermod --password `perl -e "print crypt('root','root');"` root' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin1 -- usermod --password `perl -e "print crypt('root','root');"` root' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin2 -- usermod --password `perl -e "print crypt('root','root');"` root' | sg lxd $CGROUP_SUFFIX"

sleep 5

clear

echo ''
echo "=============================================="
echo "Done: Set root password in containers.        "
echo "=============================================="
echo ''

