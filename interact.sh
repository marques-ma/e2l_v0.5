#!/bin/bash

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem
export PEER0_Provedor_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/ca.crt
export PEER0_Desenvolvedor_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/ca.crt
export PEER0_Usuario_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json

export CHANNEL_NAME=dockerchannel

CHANNEL_NAME="dockerchannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/src/github.com/eventdb/go"
CC_NAME="eventdb"

setGlobalsForPeer0Provedor() {
    export CORE_PEER_LOCALMSPID="ProvedorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Provedor_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/provedor.labenv.com/users/Admin@provedor.labenv.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

getHistory() {

    setGlobalsForPeer0Provedor

    ## Solicita dados da transacao
    echo -e '\n Digite o contêiner ID:'
    echo -e '\nChave: '
    read chave

    output=$(peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.labenv.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_Provedor_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_Desenvolvedor_CA --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_Usuario_CA -c '{"Args":["getHistoryForAsset", "'$chave'"]}' 2>&1)

    echo ${output::-2} | cut -c 157- | sed 's/\\//g' | jq .
    echo "Total de eventos associados ao contêiner: "
    echo ${output::-2} | cut -c 157- | sed 's/\\//g' | jq length
    echo -e "\n"

    echo ${output::-2} | cut -c 157- | sed 's/\\//g' | jq '.[].Value.status ' | sort | uniq -c | awk -F " " '{print "{\"Status\":" $2 ",\"count\":" $1"}"}'| jq .

}


queryAllEvents() {

    setGlobalsForPeer0Provedor

    # Armazena na var output todos os eventos recebidos da busca
    output=$(peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllEvents"]}' 2>&1)
    # echo $output | jq .
    # echo $output | jq -c --arg action "destroy" '.[] | select(.Record.Action == $action) | length'
    # echo $output | jq -c --arg action "destroy" '.[] | select(.Record.Action == $action)' | sort | uniq -c | awk -F " " '{print "{\"Last Action\":" $2 ",\"count\":" $1"}"}'| jq .
    # teste=$(echo $output | jq -r '.[].Key')

    # Armazena no array os container ID
    readarray -t arr < <(echo $output | jq -r '.[].Key')
    readarray -t nome < <(echo $output | jq -r '.[].Record.name')
    echo "qtd arr: "${#arr[@]}

    # Para cada containerID obtém os respectivos eventos
    for ((loop=0; loop<${#arr[@]}; loop++))
    do
        # linhas=$(tput lines)
        # Imprime na tela o nome, container id e a barra de progressao
        # tput cup $loop 
        echo -e "Nome: ${nome[$loop]}" 
        # tput cup $loop  50
        echo -e "Container ID: ${arr[$loop]}\n" 
        # tput cup $linhas 0
        # ProgressBar $loop ${#arr[@]}      

        # obtém o histórico de eventos do container
        historico=$(peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.labenv.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_Provedor_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_Desenvolvedor_CA --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_Usuario_CA -c '{"Args":["getHistoryForAsset", "'${arr[$loop]}'"]}' 2>&1)
        echo -e "Historico de eventos: \n$historico\n" | cut -c 157- | sed 's/\\//g'  | more | jq .
    done
}


queryLastEvent() {

    setGlobalsForPeer0Provedor

    echo -e '\nDigite o contêiner ID: '
    read chave

    output=$(peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryEvent", "'$chave'"]}' 2>&1)

    echo "Ultimo evento associado ao contêiner: "
    echo ${output} | jq .
    # echo ${output::-2} | cut -c 157- | sed 's/\\//g' | jq .
    echo -e "\n"

        # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryEvent", "'$chave'"]}'
}

queryCreator() {

    setGlobalsForPeer0Provedor

    # echo -e '\nDigite o id do container: '
    # read chave

    output=$(peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["GetCreator"]}' 2>&1)

    echo "Criador: "
    echo ${output}
    # echo ${output::-2} | cut -c 157- | sed 's/\\//g' | jq .
    echo -e "\n"

        # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryEvent", "'$chave'"]}'
}

    
menu(){


echo -e '\n*** Hyperledger Fabric Interaction *** \n'
echo -e ' **  Escolha a opcao de consulta   ** \n'
select i in "Lista eventos de container especifico" "Lista ultimo evento de container" "Lista todos os eventos registrados na blockchain" sair
    do

        case "$i" in

            "Lista eventos de container especifico")
                echo -e '\n'
                getHistory
                echo -e '\n'
                read -n 1 -s -r -p "Pressine qualquer tecla para continuar..."
                menu
                ;;

            "Lista ultimo evento de container")
                echo -e '\n'
                queryLastEvent
                echo -e '\n'
                read -n 1 -s -r -p "Pressine qualquer tecla para continuar..."
                menu
                ;;

            "Lista todos os eventos registrados na blockchain")
                echo -e '\n'
                queryAllEvents
                echo -e '\n'
                read -n 1 -s -r -p "Pressine qualquer tecla para continuar..."
                menu                
                ;;

            # queryCreator)
            #     echo -e '\n'
            #     queryCreator
            #     echo -e '\n'
            #     read -n 1 -s -r -p "Pressine qualquer tecla para continuar..."
            #     menu                
            #     ;;

            sair)
                echo -e '\n'
                echo "saindo..."
                break
                ;;

            *)
                echo "opcao invalida, tente novamente"
                ;;
                   
                   
        esac
    done

exit 0
}
menu