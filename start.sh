#!/bin/bash
set -eux

dci_topic=$1
dev_mode=""

if [ -z $dci_topic ]; then
    echo "Usage: $0 <TOPIC>"
fi

if [ -n $DEV ]; then
    dev_mode="-v ${HOME}/git_repos/dci-ansible-agent:/usr/share/dci-ansible-agent -v ${HOME}/git_repos/dci-ansible/modules:/usr/share/dci/modules -v ${HOME}/git_repos/dci-ansible/callback:/usr/share/dci/callback -v ${HOME}/git_repos/dci-ansible/module_utils:/usr/share/dci/module_utils"
fi

if [ ! -f jumpbox/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f jumpbox/id_rsa
    cp ~/.ssh/id_rsa.pub jumpbox/authorized_keys
    mv jumpbox/id_rsa.pub undercloud/authorized_keys
    cat ~/.ssh/id_rsa.pub >> undercloud/authorized_keys
fi

cp ~/dcirc_goneri_${dci_topic}.sh jumpbox/dcirc.sh
sudo docker build -t jumpbox_${dci_topic,,} --build-arg DCI_TOPIC=${dci_topic} jumpbox
sudo docker build -t undercloud_${dci_topic,,} undercloud
docker inspect jumpbox-instance_${dci_topic,,} && docker rm -f jumpbox-instance_${dci_topic,,}

test -d shared/$dci_topic && rm -r shared/$dci_topic
mkdir -p shared/$dci_topic
touch shared/$dci_topic/wait

test -d data || mkdir data
sudo chmod 777 data

docker run --cpu-quota="50000" --blkio-weight 1000 -d -v /run/docker.sock:/run/docker.sock -v $PWD/shared:/shared -v $PWD/data:/var/lib/dci-ansible-agent ${dev_mode} --stop-timeout=1 -i --name jumpbox-instance_${dci_topic,,} jumpbox_${dci_topic,,}
jumpbox_ip=$(docker inspect jumpbox-instance_${dci_topic,,}|jq -r .[].NetworkSettings.IPAddress)

father_pid_file=/proc/$$
(
    while true; do
        if test -d $father_pid_file && test -f shared/wait; then
            sleep 10
        else
            break
        fi
    done

    echo "Start the undercloud"
    docker inspect undercloud-instance_${dci_topic,,} && docker rm -f undercloud-instance_${dci_topic,,}
    docker run --cpu-quota="50000" --blkio-weight 1000 -d --stop-timeout=1 -i --name undercloud-instance_${dci_topic,,} undercloud_${dci_topic,,}
    undercloud_ip=$(docker inspect undercloud-instance_${dci_topic,,}|jq -r .[].NetworkSettings.IPAddress)
    echo ${undercloud_ip} > shared/undercloud_ip
)&

sleep 5
ssh root@${jumpbox_ip} systemctl start dci-ansible-agent

# sleep 5
# while ! ssh root@172.17.0.4 systemctl is-active dci-ansible-agent|grep failed; do
#     echo "Waiting"
#     sleep 5
# done
# docker rm -f undercloud-instance
# docker rm -f jumpbox-instance
wait
