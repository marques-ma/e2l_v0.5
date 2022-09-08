#!/bin/bash

# Define nro contêineres
echo "Digite a qtd de contêineres: ";
read limite;

# Define intervalo
echo "Digite o nro de execuções: ";
read intervalo;

for ((loop=1; loop<=$intervalo; loop++))
do
    for ((i=1; i<=$limite; i++))
    do
        # clear
        echo "Iniciando contêiner " $i
        docker run -d --name img$i alpine ping www.google.com.br
    done
    sleep 2
    for ((j=1; j<=$limite; j++))
    do
        # clear
        echo "pausando contêiner " $j
        docker pause img$j        
        sleep 1
        echo "retornando contêiner " $j
        docker unpause img$j
    done
    sleep 2
    for ((k=1; k<=$limite; k++))
    do
        # clear
        echo "Finalizando contêiner " $k
        docker rm -f img$k
    done
done
