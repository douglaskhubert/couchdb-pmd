#!/bin/bash

HOST1=admin:mysecretpassword@$(docker inspect cluster-couchdb_couchdb1_1 | jq -r '.[].NetworkSettings.Networks | .[].IPAddress'):5984
HOST2=admin:mysecretpassword@$(docker inspect cluster-couchdb_couchdb2_1 | jq -r '.[].NetworkSettings.Networks | .[].IPAddress'):5984
HOST3=admin:mysecretpassword@$(docker inspect cluster-couchdb_couchdb3_1 | jq -r '.[].NetworkSettings.Networks | .[].IPAddress'):5984


echo Criando banco de dados "pedidos" pelo HOST: $HOST1
curl -X PUT $HOST1/pedidos/

echo Criando um pedido
curl -H "Content-type: application/json" -X POST $HOST1/pedidos/ -d '
{
    "produto": {
        "nome": "Notebook",
        "preco": "R$1500,00",
        "categoria": "Informática"
    },
    "cliente": {
        "nome": "Douglas Keiller Hubert",
        "cpf": "123.456.789-12"
    }
}
' | jq

echo Informe o id do objeto criado:
read IDCRIADO

echo Consultando o pedido criado em outro HOST:  $HOST3
curl -X GET $HOST3/pedidos/$IDCRIADO | jq

echo Provocando conflito de escrita no cluster
curl -X PUT $HOST2/pedidos/$IDCRIADO -d '
{
    "produto": {
        "nome": "Notebook",
        "preco": "R$1500,00",
        "categoria": "Informática"
    },
    "cliente": {
        "nome": "Douglas K. Hubert",
        "cpf": "123.456.789-12"
    }
}
' | jq & 
curl -X PUT $HOST1/pedidos/$IDCRIADO -d '
{
    "produto": {
        "nome": "Notebook",
        "preco": "R$1500,00",
        "categoria": "Informática"
    },
    "cliente": {
        "nome": "Douglas Keiller Hubert",
        "cpf": "123.456.789-12"
    }
}' | jq &

wait

echo Buscando registro em outro HOST
curl -X GET $HOST3/pedidos/$IDCRIADO | jq

echo Adicionando parâmetro que solicita um quorum
curl -X GET $HOST1/pedidos/$IDCRIADO?r=2 | jq

echo Request com quorum de escrita incluindo todos os nós
curl -X GET $HOST2/pedidos/$IDCRIADO?w=3 | jq

echo Configurando um quorum de leitura = 2 para o pedido criado anteriormente
curl -X GET $HOST2/pedidos/$IDCRIADO?r=3 | jq

echo Inserindo novos registros
curl -H "Content-type: application/json" -X POST $HOST1/pedidos -d '
{
    "produto": {
        "nome": "Monitor",
        "preco": "R$1000,00",
        "categoria": "Informática"
    }
}' | jq
echo Informe o ID do registro criado
read IDCRIADO2

curl -H "Content-type: application/json" -X POST $HOST1/pedidos -d '
{
    "produto": {
        "nome": "Monitor",
        "preco": "R$1000,00",
        "categoria": "Informática"
    }
}' | jq
echo Informe o ID do outro registro criado
read IDCRIADO3

echo Verificando os shards do banco pedidos

curl $HOST1/pedidos | jq
read

curl $HOST1/pedidos/_shards | jq
read

echo Verificando os shards dos registros criados
curl $HOST1/pedidos/_shards/$IDCRIADO | jq
curl $HOST1/pedidos/_shards/$IDCRIADO2 | jq
curl $HOST1/pedidos/_shards/$IDCRIADO3 | jq
read

echo Deletando o banco de dados pedido
curl -X DELETE $HOST1/pedidos
