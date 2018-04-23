#!/bin/bash

NODES=$(echo node0{1..5})
PEM=~/.ssh/id.pem
#NODES=node02

if [ ! -f $HOME/.ssh_finished_configured ]; then

cat << EOF | sudo tee -a /etc/hosts
10.0.0.4 master node1
10.0.0.5 node2
10.0.0.6 node3
10.0.0.7 node4
10.0.0.8 node5
EOF

# Scan the VPC for fingerprints
ssh-keyscan -t ecdsa $NODES > /tmp/ssh_known_hosts

# generate a key for root (ecdsa to not conflict with an AWS configured RSA)
ssh-keygen -t ecdsa -f root_id_ecdsa -N ''

# generate a key for ec2-user (ecdsa ...)
ssh-keygen -t ecdsa -f ec2_id_ecdsa -N ''

# Prepare each of the nodes
for i in $NODES
do
        scp -i $PEM /tmp/ssh_known_hosts $i:/tmp
        scp -i $PEM root_id_ecdsa.pub $i:/tmp
        scp -i $PEM root_id_ecdsa $i:/tmp
	scp -i $PEM ec2_id_ecdsa.pub $i:/tmp
	scp -i $PEM ec2_id_ecdsa $i:/tmp
        ssh -i $PEM -t $i '
echo === ROOT SETUP ===
sudo cp /tmp/ssh_known_hosts /etc/ssh/ssh_known_hosts
sudo mv /tmp/root_id_ecdsa /root/.ssh/id_ecdsa
sudo chown root:root /root/.ssh/id_ecdsa
sudo cat /tmp/root_id_ecdsa.pub /root/.ssh/authorized_keys > /tmp/new_auth_keys
sudo mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys.bkp
sudo mv /tmp/new_auth_keys /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/authorized_keys
sudo chown root:root /root/.ssh/authorized_keys

echo === EC2 SETUP ===
sudo mv /tmp/ec2_id_ecdsa /home/ec2-user/.ssh/id_ecdsa
sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/id_ecdsa
sudo cat /tmp/ec2_id_ecdsa.pub /home/ec2-user/.ssh/authorized_keys > /tmp/new_auth_keys
sudo mv /home/ec2-user/.ssh/authorized_keys /home/ec2-user/.ssh/authorized_keys.bkp
sudo mv /tmp/new_auth_keys /home/ec2-user/.ssh/authorized_keys
sudo chmod 600 /home/ec2-user/.ssh/authorized_keys
sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys

'
done

touch $HOME/.ssh_finished_configured

else
        echo 'SSH already configured.'
fi
