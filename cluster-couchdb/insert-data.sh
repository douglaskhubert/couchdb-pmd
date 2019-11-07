#!/bin/bash -x

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
'

echo Informe o id do objeto criado:
read IDCRIADO

echo Consultando o pedido criado em outro HOST:  $HOST3
curl -X GET $HOST3/pedidos/$IDCRIADO

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
' & 
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
}'&

wait

echo Buscando registro em outro HOST
curl -X GET $HOST3/pedidos/$IDCRIADO

echo Configure um quorum de escrita = 2 para o db pedidos
curl -X


read
echo Deletando o banco de dados pedido
curl -X DELETE $HOST1/pedidos
