# Tutorial Couch DB
<p align="center">
  <img width="300" height="300" src="static/couchdb.png?raw=true">
</p>

## Processamento Massivo de Dados:
**Autores:**
* Douglas Keiller Hubert
* Henrique Ferreira Ramos
* Nícolas Ribeiro Vieira

Professora Dra. Sahudy Montenegro González

## Introdução
O CouchDB é um banco de dados open source desenvolvido pela Apache™ orientado à documentos. O CouchDB utiliza nativamente **json** para armazenamento de dados, **JavaScript** para sua query language, incluindo features como MapReduce e view configuration.

Por padrão, o CouchDB também suporta implementações com **RESTful API's** (e requests via curl, por exemplo), sendo uma alternativa para implementações diretas e agnósticas, devido à independência de qualquer necessidade de driver ou lib para consumir e utilizar o banco.

A título de curiosidade, o nome Couch é um acrônimo para “Cluster of Unreliable Commodity Hardware”, ou seja, cluster para máquinas de baixo poder computacional.

## Instalação
Requisitos:
* macOS ou Linux;
* Docker;

Uma vez com o docker instalado e apropriadamente configurado, basta instalar a [imagem disponibilizada do CouchDB no hub do docker](https://hub.docker.com/_/couchdb):

```
docker pull couchdb:2.3.1
docker run -p 5984:5984 -d couchdb
```
Uma vez rodado ambos comandos, o Docker subirá uma instância do CouchDB.

Por padrão, o CouchDB roda na porta 5984, neste caso, com a flag **-p** estamos expondo esta porta do container em nossa máquina/rede.

A versão utilizada neste tutorial foi a latest, que até o presente dia (22/10/2019) é listada como a *latest* do repositório.

Para validar se a instância está rodando localmente e operante, basta executar:
```
curl http://127.0.0.1:5984/
```
> {"couchdb":"Welcome","version":"2.3.1","git_sha":"c298091a4","uuid":"6f1d0edf36f2ade32a3ac9faf3443dfe","features":["pluggable-storage-engines","scheduler"],"vendor":{"name":"The Apache Software Foundation"}}


PS: Caso deseje parar o container do docker, basta suspender o container com sua id
```
docker stop <container_id>
```

## Configuração Básica

É possível configurar e utilizar o CouchDB através de duas maneiras:
* **API** - Nativa;
* Interface/Browser via **Fauxton**(antigo Futon)

Na primeira execução, o Couch rodará no chamado *admin-party mode*, no qual não há um admnistrador definido.

É possível configurar a primeira ocasião utilizando o Fauxton - [via interface](http://127.0.0.1:5984/_utils/#/setup).
Clique no botão "Configure a Single Node" para configurar uma réplica inicial. Neste primeiro setup, não introduziremos réplicas ou mesmo clusters, que também são features suportadas pelo CouchDB

É necessário introduzir e configurar um admin durante o setup, utilizaremos:
**user**: admin
**password**: 1234

Uma vez configurado, esta será a autenticação utilizada para criar novos usuários, databases, inserir dados etc. Seja via interface ou curl.

## Comandos Básicos


# Implementação de Propriedades no CouchDB

Nesta parte do tutorial, vamos falar um pouco sobre como o CouchDB implementa as seguintes propriedades:

* Consistência
* Disponibilidade
* Tolerância a particionamento

Porém, antes disso, daremos uma olhada rápida sobre o que a documentação do CoachDB tem a nos dizer sobre
o teorema CAP. Como uma imagem vale mais do que mil palavras:

<p align="center">
  <img width="300" height="300" src="static/cap-theorem-couchdb.png?raw=true">
</p>

Podemos ver que o CouchDB se encontra na intersecção entre **Tolerância a Particionamento** e **Disponibilidade**. Logo, podemos
dizer que o CouchDB possui uma consistência eventual, em outras palavras, mais cedo ou mais tarde os dados estarão consistentes.

## Consistência
O CouchDB faz uso de Controle de Concorrência de Múltiplas Versões ou somente MVCC (Multiversion Concurrency Control), o que permite que diversos acessos sejam feitos ao mesmo dado de forma simultânea, sendo assim, teremos uma disponibilidade dos dados bastante expressiva e com isso, alta escalabilidade.

Sempre que um usuário queira realizar uma alterção nos dados, estes dados não serão bloqueados aos demais usuários do banco, porém será disponibilizada uma versão anterior dos dados, o que caracteriza a consistência eventual usando replicação incremental presente no CouchDB. O sistema de replicação do CouchDB vem com detecção e resolução automáticas de conflitos. Quando o CouchDB detecta que um documento foi alterado em dois bancos de dados, sinaliza esse documento como estando em conflito, como se estivessem em um sistema de controle de versão regular.

O CouchDB trabalha com replicação no conceito Mestre-Mestre onde o CouchDB comparará o banco de dados de origem e destino para determinar quais documentos diferem entre o banco de dados de origem e destino. Isso é feito seguindo os Feeds de alterações na origem e comparando os documentos com o destino. As alterações são enviadas para o destino em lotes onde eles podem introduzir conflitos. Os documentos que já existem no destino na mesma revisão não são transferidos. Como a exclusão de documentos é representada por uma nova revisão, um documento excluído na fonte também será excluído no destino.

Uma tarefa de replicação será concluída assim que chegar ao final do feed de alterações. Se sua propriedade contínua estiver configurada como true, aguardará a exibição de novas alterações até que a tarefa seja cancelada. As tarefas de replicação também criam documentos de ponto de verificação no destino para garantir que uma tarefa reiniciada possa continuar de onde parou, por exemplo, após a falha.

## Transações e propriedades ACID


## Disponibilidade


## Escalabilidade




