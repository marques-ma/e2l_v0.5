export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem
export PEER0_PROVEDOR_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/ca.crt
export PEER0_DESENVOLVEDOR_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/ca.crt
export PEER0_USUARIO_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/
export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json

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

presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/src/github.com/eventdb/go
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}

CHANNEL_NAME="dockerchannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/src/github.com/eventdb/go"
CC_NAME="eventdb"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Provedor
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.Provedor ===================== "
}

installChaincode() {
    setGlobalsForPeer0Provedor
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.Provedor ===================== "

    setGlobalsForPeer0Desenvolvedor
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.Desenvolvedor ===================== "

    setGlobalsForPeer0Usuario
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.Usuario ===================== "

}


queryInstalled() {
    setGlobalsForPeer0Provedor
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.Provedor on channel ===================== "
}

approveForProvedor() {
    setGlobalsForPeer0Provedor
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.labenv.com --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from Provedor ===================== "

}


getBlock() {
    setGlobalsForPeer0Provedor


    peer channel getinfo  -c dockerchannel -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.labenv.com --tls \
        --cafile $ORDERER_CA
}

checkCommitReadyness() {
    setGlobalsForPeer0Provedor
    peer lifecycle chaincode checkcommitreadiness \
        --collections-config $PRIVATE_DATA_CONFIG \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Provedor ===================== "
}

approveForDesenvolvedor() {
    setGlobalsForPeer0Desenvolvedor

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.labenv.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --collections-config $PRIVATE_DATA_CONFIG \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from Desenvolvedor ===================== "
}

checkCommitReadyness() {

    setGlobalsForPeer0Desenvolvedor
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PROVEDOR_CA \
        --collections-config $PRIVATE_DATA_CONFIG \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Provedor ===================== "
}

approveForUsuario() {
    setGlobalsForPeer0Usuario

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.labenv.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --collections-config $PRIVATE_DATA_CONFIG \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from Usuario ===================== "
}

checkCommitReadyness() {

    setGlobalsForPeer0Usuario
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PROVEDOR_CA \
        --collections-config $PRIVATE_DATA_CONFIG \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Provedor ===================== "
}

commitChaincodeDefination() {
    setGlobalsForPeer0Provedor
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.labenv.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --collections-config $PRIVATE_DATA_CONFIG \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PROVEDOR_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_DESENVOLVEDOR_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_USUARIO_CA \
        --version ${VERSION} --sequence ${VERSION} --init-required

}

queryCommitted() {
    setGlobalsForPeer0Provedor
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

chaincodeInvokeInit() {
    setGlobalsForPeer0Provedor
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.labenv.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PROVEDOR_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_DESENVOLVEDOR_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_USUARIO_CA \
        --isInit -c '{"Args":[]}'

}

chaincodeInvoke() {
    setGlobalsForPeer0Provedor

    # Init ledger
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.labenv.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PROVEDOR_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_DESENVOLVEDOR_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_USUARIO_CA \
        -c '{"function": "initLedger","Args":[]}'
}

chaincodeQuery() {
    setGlobalsForPeer0Desenvolvedor

    # Query event by Id
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryEvent","Args":["EVENT0"]}'

}

presetup
# 
packageChaincode
installChaincode
queryInstalled
approveForProvedor
checkCommitReadyness
approveForDesenvolvedor
checkCommitReadyness
approveForUsuario
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
