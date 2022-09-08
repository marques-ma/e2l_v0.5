# e2L - Event to Ledger
This repository is part of the work submitted to SBSEG 2022 - Salão de ferramentas, containing the necessary files to execute the proof of concept environment proposed in the work.  
This code is distributed under GPLv3.

## Authors
Marco Antonio Marques - marcomarques@usp.br  
Charles Christian Miers - ccm777@gmail.com  
Marcos Antonio Simplicio Jr. - mjunior@larc.usp.br  

## Introduction
This repository contains all necessary files to execute the proposed event2ledger proof of concept and also all proposed solution documentation.

The implementation can be performed in two ways: in a single host, as presented in demonstration, or in a bigger and more complex scenario, involving any container orchestration plataform.

## Pre requisites
The pre requisites to install the proof of concept scenario is highly tied with the Hyperledger Fabric blockchain. Considering this, we can assume HLF requisites as also event2ledger minimum requisites to implement and execute the proposed solution.  

To install all necessary pre requisites, you can run the preinstall.sh script, available at repository.

## Environment and event2ledger execution procedure

To ease the process of starting and configurating all the necessary components, in the repository is available a script named start.sh.  

The first step executed in the script is the creation of the crypto material necessary to perform all cryptographic tasks. To do this, it navigates to /artifacts/channel and execute _**create-artifacts.sh**_  

The second step is to create and execute the containers that compose the Hyperledger Fabric blockchain. This process uses the docker-compose.yaml file available at /artifacts. To perform this step, the script navigate to this directory and execute docker-compose up -d.  

Then, it is time to create the Hyperledger Fabric channel, join the nodes, install and approve the chaincode. These steps are performed with the auxiliary scripts createchannel.sh and deploychaincode.sh, also available at repository root.  

At this point, the blockchain should be up and running. The next step, then, is to install the API dependencies before its first run. This can be done navegating to /api-1.4 and running the command npm install.  

After the modules installation, the API execution can be performed using the command nodemon app, at the same directory.

This procedure makes the API available to answer calls from the collectors.

To execute the collector instance, navigate to /1-e2l.mgr and execute the event2ledgerv1.0.sh script, that will conect to local Docker daemon and listen to incoming container events.

## Execution and validation tests

To validate event2ledger functionality, we propose some basic tests that will simulate a container life cycle, composed by its creation, pause, resume, and destroy.  

An additional script, called genevents.sh, is available to ease the process of validation. This ask as input the number of containers and the number of executions to be performed. Its execution will output results from events generation.  

Its also available a way to interact with the blockchain and query the added events, through the interact.sh. In this script, the user can query all the events in blockchain, or only the events related to a specific ContainerID.

## Blockchain Explorer

The repository includes an additional Hyperledger tool, called Blockchain Explorer, that offers an intuitive dashboard to reach valuable information about the running blockchain. To execute blockchain explorer, navigate to /blockchainexplorer, and execute docker-compose up -d.  

It will start two new containers that will communicate with the blockchain and offer an interface available at localhost:8080

# Useful informations: Update notes

- Blockchain explorer com config.json;
- event2Ledger;
# e2l_v2
- Blockchain com 3 peers cada org
# e2lv03
- Modificação no chaincode, usa o contêiner ID como índice.
- 3 instâncias do e2l. Modelo final encontra-se no dir 3-... Possui script ./recreate.sh, que gera o token JWT e o contêiner, e passa o token como argumento para o e2l;
- Nova versão do script ./interact.sh:
    - Adicionada função getallevents, que lista todos os contêineres ID e apresenta totalização de contêineres e eventos por tipo.
    - Adicionada função que recebe o containerID e retorna o histórico de eventos referente.
# e2lv031
- Nova versão do script ./interact.sh:
    - Progressbar inserida
    - Resultados em interface gráfica
    - Removidos createevent e changeeventowner
# e2lv04
    - Atualização do chaincode. A função createEvent passa a registrar o CommonName de quem enviou a transação e o TxID para facilitar posterior validação.
    - Script interact atualizado:
        - getAllEvents passa a verificar a validade das transações via TxID, a partir do qual verifica se o validationCode é 0 (trans. válida). Ao final apresenta o total de transações válidas e inválidas.
# e2lv041
    - Script interact atualizado, com criação da função contvalidas e ajuste na progressbar.
# e2l_v0.5
    - Correção de bugs no script interact, que gerava erro no parse do jq .  
