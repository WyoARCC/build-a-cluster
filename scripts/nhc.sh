#!/bin/bash

wget https://github.com/mej/nhc/releases/download/1.4.2/lbnl-nhc-1.4.2-1.el4.noarch.rpm

sudo cp lbnl-nhc-1.4.2-1.el4.noarch.rpm \
	/var/www/html/hpc-repo/Packages/

cd /var/www/html/hpc-repo

sudo createrepo $(pwd)

sudo clush -w @all sudo yum makecache fast

sudo clush -w @all sudo yum install -y lbnl-nhc

sudo vim /etc/nhc/nhc.conf

# Make some edits for the nodes

# Copy file to all nodes

# Run by hand
