
chmod -R 0755 ./crypto-config
# Delete existing artifacts
rm -rf ./crypto-config
rm genesis.block dockerchannel.tx
rm -rf ../../channel-artifacts/*

#Generate Crypto artifactes for organizations
cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/



# # System channel
SYS_CHANNEL="sys-channel"

# # channel name defaults to "mychannel"
CHANNEL_NAME="dockerchannel"

echo $CHANNEL_NAME

# # Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block


# # Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./dockerchannel.tx -channelID $CHANNEL_NAME

 echo "#######    Generating anchor peer update for ProvedorMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./ProvedorMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ProvedorMSP

 echo "#######    Generating anchor peer update for DesenvolvedorMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./DesenvolvedorMSPanchors.tx -channelID $CHANNEL_NAME -asOrg DesenvolvedorMSP

 echo "#######    Generating anchor peer update for UsuarioMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./UsuarioMSPanchors.tx -channelID $CHANNEL_NAME -asOrg UsuarioMSP