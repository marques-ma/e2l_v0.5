export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem
export PEER0_PROVEDOR_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/ca.crt
export PEER0_DESENVOLVEDOR_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/ca.crt
export PEER0_USUARIO_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=dockerchannel

setGlobalsForOrderer(){
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/labenv.com/users/Admin@labenv.com/msp
    
}

setGlobalsForPeer0Provedor(){
    export CORE_PEER_LOCALMSPID="ProvedorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PROVEDOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/provedor.labenv.com/users/Admin@provedor.labenv.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Desenvolvedor(){
    export CORE_PEER_LOCALMSPID="DesenvolvedorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DESENVOLVEDOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/desenvolvedor.labenv.com/users/Admin@desenvolvedor.labenv.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    
}

setGlobalsForPeer0Usuario(){
    export CORE_PEER_LOCALMSPID="UsuarioMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_USUARIO_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/usuario.labenv.com/users/Admin@usuario.labenv.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
    
}

createChannel(){
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Provedor
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.labenv.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

removeOldCrypto(){
    rm -rf ./api-1.4/crypto/*
    rm -rf ./api-1.4/fabric-client-kv*
}


joinChannel(){
    setGlobalsForPeer0Provedor
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer0Desenvolvedor
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0Usuario
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

updateAnchorPeers(){
    setGlobalsForPeer0Provedor
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.labenv.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Desenvolvedor
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.labenv.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    setGlobalsForPeer0Usuario
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.labenv.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
}

removeOldCrypto

createChannel
joinChannel
updateAnchorPeers