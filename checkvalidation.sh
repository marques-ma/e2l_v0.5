#!/bin/bash

# newjwt () {
    clear
    getjwt=$(curl --location --request POST 'http://localhost:4000/users' --header 'Content-Type: application/json' --data-raw '{ "username":"test", "orgName":"Usuario"}')
    echo $getjwt
# }

# Armazena token na var
read token < <(echo $getjwt | jq -r '.token')

# checkvalidation () {
    echo "Informe o TxID: "
    read TxID
    validationstatus=$(curl --location --request GET "http://localhost:4000/channels/dockerchannel/transactions/"$TxID"?peer=peer0.provedor.labenv.com" --header "Authorization: Bearer "$token"")
    echo -e "\n RESULTADO: "
    echo $validationstatus | jq ".validationCode"

# }
