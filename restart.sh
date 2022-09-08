#!/bin/bash

clear 
echo "Removing API material..." 
rm -rf ./api-1.4/fabric-client-kv-* 

cd ./blockchainexplorer
docker-compose down --remove-orphans
sleep 3
cd ../artifacts/
echo "Turning off..."
docker-compose down --remove-orphans
sleep 3
echo "Removing volumes..."
docker volume prune -f
sleep 3
echo "Removing networks..."
docker network prune -f

cd ./channel 
echo "Creating artifacts..."
./create-artifacts.sh
sleep 1

cd ..
echo "Network up..."
docker-compose up -d
sleep 5

cd ..
echo "Creating channel..."
./createChannel.sh 
sleep 2
echo "Deploying chaincode..."
./deployChaincode.sh
sleep 2

# echo "Starting blockchain explorer..."
# cd ./blockchainexplorer
# docker-compose up -d
# sleep 2