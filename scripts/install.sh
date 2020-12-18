#!/bin/bash
# encoding: utf-8

echo "#####################################################################"
echo "Checking OS version"
echo "#####################################################################"
os=$(uname)
if [[ ! $os == "Linux" ]]; then
  echo "Not a Linux system. Unable to initialize setup"
  exit 1
fi

echo "#####################################################################"
echo "Installing system dependencies"
echo "#####################################################################"
sudo apt install -y vim htop tmux

echo "#####################################################################"
echo "Installing Docker"
echo "#####################################################################"
curl -fsSL https://get.docker.com -o get-docker.sh | sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

echo "#####################################################################"
echo "Installing Docker Compose"
echo "#####################################################################"
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
