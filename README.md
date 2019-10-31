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

Para criar uma database via curl, utilizaremos o seguinte padrão:
```
curl -X PUT http://usuario:senha@host:port/nome_database
```
Note a presença do username com criado e a senha do mesmo, bem como o host (IP) e a porta do servidor local.

Para criar a database chamada teste:
```
curl -X PUT http://admin:1234@127.0.0.1:5984/teste
```
>{"ok":true}

Para ver todas as dbs presentes no servidor:
```
curl -X GET http://admin:1234@127.0.0.1:5984/_all_dbs
```
>["_global_changes","_replicator","_users","teste"]

Perceba que todas as inputs retornam valores em formatos conhecidos - muitos na notação JSON.

Antes de realizar inserts, é recomendável gerar  *Universally Unique Identifiers* (UUIDs) da própria instância do Couch - essa abordagem é ideal para que não haja chaves duplicadas dentro do banco.

Retorna uma UUID:
```
curl -X GET http://admin:1234@127.0.0.1:5984/_uuids
```
>{"uuids":["21a2cc36dc2dd7edb69352fb570009f4"]}

É possível também retornar mais de uma chave para evitar *overflow* de requests na API:
```
curl -X GET http://admin:1234@127.0.0.1:5984/_uuids?count=10
```
### Utilizando a DB Teste

Para utilizarmos a DB teste, basta utilizar na mesma lógica de uma API rest - se adiciona o nome da database um pouco antes do request. Neste tópico, o CouchDB leva vantagem sobre qualquer sistema SQL tradicional pela simplicidade. Em um sistema SQL tradicional seria necessário criar novos clientes de conexão em um aplicacão para se consumir mais de uma database.

Com um simples comando, é possível observar as informações macros da Database:
```
curl -X GET http://admin:1234@127.0.0.1:5984/teste 
```
>{"db_name":"teste","purge_seq":"0-g1AAAAEzeJzLYWBg4MhgTmHgzcvPy09JdcjLz8gvLskBCjPlsQBJhgNA6v____ezEhnwqnsAUfefkLoFEHX7CalrgKibj1tdkgKQTLLHa2dSAkhNPX41DiA18XjVJDIkyUMUZAEAuYBi9g","update_seq":"0-g1AAAAEzeJzLYWBg4MhgTmHgzcvPy09JdcjLz8gvLskBCjMlMiTJ____PyuRAYeCJAUgmWSPX40DSE08fjUJIDX1eNXksQBJhgYgBVQ2n5C6BRB1-wmpOwBRd5-QugcQdSD3ZQEAiJJi9g","sizes":{"file":33960,"external":0,"active":0},"other":{"data_size":0},"doc_del_count":0,"doc_count":0,"disk_size":33960,"disk_format_version":7,"data_size":0,"compact_running":false,"cluster":{"q":8,"n":1,"w":1,"r":1},"instance_start_time":"0"}

Neste comando, é retornado os status de cluster, total de documentos, uma purge_sequence, quantidade de documentos, tamanho em disco e informações da instância.

Para obter **todos** documentos presentes na view:
```
curl -X GET http://admin:1234@127.0.0.1:5984/teste/_all_docs
```
>{"total_rows":0,"offset":0,"rows":[]}




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

Sempre que um usuário queira realizar uma alterção nos dados, estes dados não serão bloqueados aos demais usuários do banco, porém será disponibilizada uma versão anterior dos dados, o que caracteriza a consistência eventual presente no CouchDB.

## Transações e propriedades ACID
## Disponibilidade
## Escalabilidade




