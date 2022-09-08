#!/bin/bash

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../artifacts/channel/crypto-config/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem
export PEER0_PROVEDOR_CA=${PWD}/../artifacts/channel/crypto-config/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/ca.crt
export PEER0_DESENVOLVEDOR_CA=${PWD}/../artifacts/channel/crypto-config/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/ca.crt
export PEER0_USUARIO_CA=${PWD}/../artifacts/channel/crypto-config/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/ca.crt
export CHANNEL_NAME="dockerchannel"
export CC_NAME="eventdb"
export FABRIC_CFG_PATH="../artifacts/channel/config"

setGlobalsForPeer0Provedor() {
    export CORE_PEER_LOCALMSPID="ProvedorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PROVEDOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../artifacts/channel/crypto-config/peerOrganizations/provedor.labenv.com/users/Admin@provedor.labenv.com/msp 
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Provedor
# Monitor all Docker events
docker events --filter 'type=service' --filter 'type=container' --format '{{json .}}' | while read event 

do
echo "valor de event:""$event"
# echo "$event" | jq '.Type'
tipo=$(echo "$event" | jq '.Type')
# echo ${tipo:1:-1}

    if [ "${tipo:1:-1}" = "service" ]; then
    
        tipo=$(echo "$event" | jq '.Type')
        acao=$(echo "$event" | jq '.Action')
        actorID=$(echo "$event" | jq '.Actor.ID')
        nome=$(echo "$event" | jq '.Actor.Attributes.name')
        replicasnew=$(echo "$event" | jq '.Actor.Attributes."replicas.new"')
        replicasold=$(echo "$event" | jq '.Actor.Attributes."replicas.old"')
        escopo=$(echo "$event" | jq '.scope')
        hora=$(echo "$event" | jq '.time')
        horanano=$(echo "$event" | jq '.timeNano')

        peer chaincode invoke -o localhost:7050 \
            --ordererTLSHostnameOverride orderer.labenv.com \
            --tls $CORE_PEER_TLS_ENABLED \
            --cafile $ORDERER_CA \
            -C $CHANNEL_NAME -n ${CC_NAME} \
            --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PROVEDOR_CA \
            --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_DESENVOLVEDOR_CA \
            --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_USUARIO_CA \
            -c '{"Args":["createEvent", "'${actorID:1:-1}'", "'${tipo:1:-1}'", "'${acao:1:-1}'", "'${actorID:1:-1}'", "'${nome:1:-1}'", "'${replicasnew:1:-1}'", "'${replicasold:1:-1}'", "'${escopo:1:-1}'", "'$hora'", "'$horanano'"]}' 
            
    else
        if [ "${tipo:1:-1}" = "container" ]; then
        
            status=$(printf '%s' "$event" | jq '.status')
            id=$(printf '%s' "$event" | jq '.id')
            from=$(printf '%s' "$event" | jq '.from')
            tipo=$(printf '%s' "$event" | jq '.Type')
            acao=$(printf '%s' "$event" | jq '.Action')
            actorID=$(printf '%s' "$event" | jq '.Actor.ID')
            imagem=$(printf '%s' "$event" | jq '.Actor.Attributes.image')
            nome=$(printf '%s' "$event" | jq '.Actor.Attributes.name')
            escopo=$(printf '%s' "$event" | jq '.scope')
            hora=$(printf '%s' "$event" | jq '.time')
            horanano=$(printf '%s' "$event" | jq '.timeNano')

            peer chaincode invoke -o localhost:7050 \
                --ordererTLSHostnameOverride orderer.labenv.com \
                --tls $CORE_PEER_TLS_ENABLED \
                --cafile $ORDERER_CA \
                -C $CHANNEL_NAME -n ${CC_NAME} \
                --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PROVEDOR_CA \
                --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_DESENVOLVEDOR_CA \
                --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_USUARIO_CA \
                -c '{"Args":["createEvent", "'${actorID:1:-1}'", "'${status:1:-1}'", "'${id:1:-1}'", "'${from:1:-1}'", "'${tipo:1:-1}'", "'${acao:1:-1}'", "'${actorID:1:-1}'", "'${imagem:1:-1}'", "'${nome:1:-1}'", "'${escopo:1:-1}'", "'$hora'", "'$horanano'"]}' 
        
        
        fi
    fi


done
