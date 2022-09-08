#!/bin/bash

# Script developed to install all pre-requisites necessary to run Event2ledger proof-of-concept in Linux Ubuntu 20.04
# and Debian 11. Not tested in other environments yet.

clear
echo -e 'Preparing... \n'
cd /
sudo mkdir tempdown

# Install GIT e cUrl
echo -e '\nInstalling GIT and cUrl... \n'
sudo apt install git
sudo apt install curl

# Install Docker
echo -e '\nInstalling Docker... \n'
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
echo -e '\n Create docker group and add user... \n'
sudo groupadd docker
sudo usermod -aG docker $USER

# Install Docker Compose
echo -e "\nnInstalling Docker Compose...\n"
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Hyperledger Fabric binaries and fabric samples
echo -e "\nnInstalling Hyperledger Fabric binaries and fabric samples...\n"
curl -sSL https://bit.ly/2ysbOFE | bash -s

# Install Node
echo -e "\nInstalling Node...\n"
cd tempdown
VERSION=v18.8.0
DISTRO=linux-x64
wget https://nodejs.org/dist/$VERSION/node-$VERSION-$DISTRO.tar.xz
sudo mkdir -p /usr/local/lib/nodejs
sudo tar -xJvf node-$VERSION-$DISTRO.tar.xz -C /usr/local/lib/nodejs

# Install Go
echo -e "\nInstalling Go...\n"
wget https://go.dev/dl/go1.19.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.1.linux-amd64.tar.gz

# Install NPM
echo -e "\nInstalling NPM...\n"
apt install npm

# Install SSH
echo -e "\nInstalling SSH...\n"
sudo apt-get install openssh-server

Add configs in bashrc
echo -e "\nAdding configs in bashrc...\n"
echo '# Hyperledger Fabric binaries' >> ~/.bashrc
echo 'export PATH=/fabric-samples/bin:$PATH' >> ~/.bashrc

echo '# Nodejs' >> ~/.bashrc
echo 'VERSION=v12.19.0' >> ~/.bashrc
echo 'DISTRO=linux-x64' >> ~/.bashrc
echo 'export PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$PATH' >> ~/.bashrc

echo '# Go' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

echo -e 'Pre-requisites installation finished. \n'