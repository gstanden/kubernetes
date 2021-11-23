#!/bin/bash

echo ''
echo "=============================================="
echo "Curl mirrorlist.centos.org...        "
echo "=============================================="
echo ''

Status=1
n=1
while [ $Status -ne 0 ] || [ $n -le 5 ]
do
        eval echo "'/var/lib/snapd/snap/bin/lxc exec $i -- curl mirrrorlist.centos.org | sg lxd $CGROUP_SUFFIX"
        Status=`echo $?`
        echo "Status = "$Status
        n=$((n+1))
        sleep 5
done

echo ''
echo "=============================================="
echo "Done: Curl mirrorlist.centos.org.             "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Ping mirrorlist.centos.org...                 "
echo "=============================================="
echo ''

ping -4 -c 10 mirrorlist.centos.org

echo ''
echo "=============================================="
echo "Done: Ping mirrorlist.centos.org.             "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Install packages...                           "
echo "=============================================="
echo ''

n=1
Cmd0=1
while [ $Cmd0 -ne 0 ] && [ $n -le 5 ]
do
	dnf check-update socat
	Cmd0=`echo $?`
        n=$((n+1))
        sleep 5
done

n=1
Cmd0=1
while [ $Cmd0 -ne 0 ] && [ $n -le 5 ]
do
        dnf upgrade -y --refresh
        Cmd0=`echo $?`
        n=$((n+1))
        sleep 5
done

dnf -y install yum-utils device-mapper-persistent-data lvm2 epel-release
dnf -y install iproute-tc net-tools openssh-server perl bind-utils
dnf -y install epel-release
dnf -y install sshpass

echo ''
echo "==============================================" 
echo "Done: Install packages.                       "
echo "=============================================="
echo ''

# if LXD container will be running on XFS file system
# dnf install -y xfsprogs xfsprogs-devel xfsdump 

echo ''
echo "==============================================" 
echo "Enable and tune sshd...                       "
echo "=============================================="
echo ''

systemctl enable sshd
service sshd start
sed -i '/GSSAPIAuthentication no/s/^#//g' 			/etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' 	/etc/ssh/sshd_config
sed -i '/UseDNS/s/^#//g' 					/etc/ssh/sshd_config
sed -i 's/UseDNS yes/UseDNS no/' 				/etc/ssh/sshd_config
service sshd stop
service sshd start
service sshd status

echo ''
echo "==============================================" 
echo "Done: Enable and tune sshd.                   "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Remove package runc...                        "
echo "=============================================="
echo ''

dnf remove -y runc

echo ''
echo "==============================================" 
echo "Done: Remove package runc.                    "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Set root user password ...                    "
echo "=============================================="
echo ''

usermod --password `perl -e "print crypt('root','root');"` root

sleep 5

clear

echo ''
echo "==============================================" 
echo "Done: Set root user password.                 "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Configure Docker repo...                      "
echo "=============================================="
echo ''

n=1
Cmd0=1
while [ $Cmd0 -ne 0 ] && [ $n -le 5 ]
do
 	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	Cmd0=`echo $?`
	n=$((n+1))
	sleep 5
done

echo ''
echo "==============================================" 
echo "Configure Docker repo...                      "
echo "=============================================="
echo ''

sleep 5

clear
 
mkdir -p /etc/docker

echo ''
echo "==============================================" 
echo "Install Docker ...                            "
echo "=============================================="
echo ''
 
n=1
Cmd1=1
while [ $Cmd1 -ne 0 ] && [ $n -le 5 ]
do
 	dnf install containerd.io docker-ce docker-ce-cli -y
	Cmd1=`echo $?`
	n=$((n+1))
	sleep 5
done

echo ''
echo "==============================================" 
echo "Done: Install Docker.                         "
echo "=============================================="
echo ''
 
sleep 5

clear 

