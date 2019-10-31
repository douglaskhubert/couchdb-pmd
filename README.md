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

## Tabela de conteúdo

* [Introdução](#introducao)
* [Instalação](#instalacao)
    * [Configuração Básica](#configuracao-basica)
* [Comandos Básicos](#comandos-basicos)
* [Implementação de Propriedades](#implementacao-propriedades)

# <a name="introducao"></a>Introdução
O CouchDB é um banco de dados open source desenvolvido pela Apache™ orientado à documentos. O CouchDB utiliza nativamente **json** para armazenamento de dados, **JavaScript** para sua query language, incluindo features como MapReduce e view configuration.

Por padrão, o CouchDB também suporta implementações com **RESTful API's** (e requests via curl, por exemplo), sendo uma alternativa para implementações diretas e agnósticas, devido à independência de qualquer necessidade de driver ou lib para consumir e utilizar o banco.

A título de curiosidade, o nome Couch é um acrônimo para “Cluster of Unreliable Commodity Hardware”, ou seja, cluster para máquinas de baixo poder computacional.

# <a name="instalacao"></a>Instalação
Requisitos:
* macOS ou Linux;
* Docker;

Uma vez com o docker instalado e apropriadamente configurado, basta instalar a [imagem disponibilizada do CouchDB no hub do docker](https://hub.docker.com/_/couchdb):

```
$ docker pull couchdb:2.3.1
$ docker run -p 5984:5984 -d couchdb
```
Uma vez rodado ambos comandos, o Docker subirá uma instância do CouchDB.

Por padrão, o CouchDB roda na porta 5984, neste caso, com a flag **-p** estamos expondo esta porta do container em nossa máquina/rede.

A versão utilizada neste tutorial foi a latest, que até o presente dia (22/10/2019) é listada como a *latest* do repositório.

Para validar se a instância está rodando localmente e operante, basta executar:
```
$ curl http://127.0.0.1:5984/
```
```json
 {
     "couchdb": "Welcome",
     "version": "2.3.1",
     "git_sha": "c298091a4",
     "uuid": "6f1d0edf36f2ade32a3ac9faf3443dfe",
     "features": [
         "pluggable-storage-engines",
         "scheduler"
     ],
     "vendor": {
         "name":"The Apache Software Foundation"
     }
 }
```

PS: Caso deseje parar o container do docker, basta suspender o container com sua id
```
$ docker stop <container_id>
```

## <a name="configuracao-basica"></a>Configuração Básica

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

# <a name="comandos-basicos"></a>Comandos Básicos

Para criar uma database via curl, utilizaremos o seguinte padrão:

```
$ curl -X PUT http://usuario:senha@host:port/nome_database
```
Note a presença do username com criado e a senha do mesmo, bem como o host (IP) e a porta do servidor local.

Para criar a database chamada teste:

```
$ curl -X PUT http://admin:1234@127.0.0.1:5984/teste
```

```json
{"ok":true}
```

Para ver todas as dbs presentes no servidor:

```
$ curl -X GET http://admin:1234@127.0.0.1:5984/_all_dbs
```

>["_global_changes","_replicator","_users","teste"]

Perceba que todas as inputs retornam valores em formatos conhecidos - muitos na notação JSON.

Antes de realizar inserts, é recomendável gerar  *Universally Unique Identifiers* (UUIDs) da própria instância do Couch - essa abordagem é ideal para que não haja chaves duplicadas dentro do banco.

Retorna uma UUID:
```
$ curl -X GET http://admin:1234@127.0.0.1:5984/_uuids
```
```json
{"uuids":["21a2cc36dc2dd7edb69352fb570009f4"]}
```

É possível também retornar mais de uma chave para evitar *overflow* de requests na API:
```
curl -X GET http://admin:1234@127.0.0.1:5984/_uuids?count=10
```
### Utilizando a DB Teste

Para utilizarmos a DB teste, basta utilizar na mesma lógica de uma API rest - se adiciona o nome da database um pouco antes do request. Neste tópico, o CouchDB leva vantagem sobre qualquer sistema SQL tradicional pela simplicidade. Em um sistema SQL tradicional seria necessário criar novos clientes de conexão em um aplicacão para se consumir mais de uma database.

Com um simples comando, é possível observar as informações macros da Database:

```json
$curl -X GET http://admin:1234@127.0.0.1:5984/teste   
{
    "db_name": "teste",
    "purge_seq": "0-g1AAAAEzeJzLYWBg4MhgTmHgzcvPy09JdcjLz8gvLskBCjPlsQBJhgNA6v____ezEhnwqnsAUfefkLoFEHX7CalrgKibj1tdkgKQTLLHa2dSAkhNPX41DiA18XjVJDIkyUMUZAEAuYBi9g",
    "update_seq": "0-g1AAAAEzeJzLYWBg4MhgTmHgzcvPy09JdcjLz8gvLskBCjMlMiTJ____PyuRAYeCJAUgmWSPX40DSE08fjUJIDX1eNXksQBJhgYgBVQ2n5C6BRB1-wmpOwBRd5-QugcQdSD3ZQEAiJJi9g",
    "sizes": {
        "file": 33960,
        "external": 0,
        "active": 0
    },
    "other": {
        "data_size": 0
    },
    "doc_del_count": 0,
    "doc_count": 0,
    "disk_size": 33960,
    "disk_format_version": 7,
    "data_size": 0,
    "compact_running": false,
    "cluster": {
        "q":8,
        "n":1,
        "w":1,
        "r":1
    },
    "instance_start_time": "0"
}
```

Neste comando, é retornado os status de cluster, total de documentos, uma purge_sequence, quantidade de documentos, tamanho em disco e informações da instância.

Para obter **todos** documentos presentes na view:
```
$ curl -X GET http://admin:1234@127.0.0.1:5984/teste/_all_docs
```
```json
{
    "total_rows": 0,
    "offset": 0,
    "rows": []
}
```

#<a name="implementacao-propriedades"></a> Implementação de Propriedades no CouchDB

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

O CouchDB implementa ACID em todas as características ACID que são atomicidade, consistência, isolamento e durabilidade. Como são geradas sempre novas versões do documento, muito similar ao que já ocorre com as ferramentas de controle de versão de arquivos como por exemplo o Git, os documentos não ficam travados e principalmente, com o estado consistente. Alterações nos documentos (adicionar, editar, deletar) são serializadas, exceto os blobs binários que são escritos concorrentemente. Leituras no banco nunca são bloqueadas (lock) e nunca tem que esperar por escritas ou outras leituras. Os documentos são indexados em b-trees pelo seu nome (DocID) e um ID de sequência. Cada atualização para uma instância de banco de dados gera um novo número sequencial. IDs de sequência são usados depois para encontrar as mudanças de forma incremental em uma base de dados. Esses índices b-trees (árvores B) são atualizados simultaneamente quando os documentos são salvos ou deletados.

Quando os documentos do CouchDB são atualizados, todos os dados e índices associados são “descarregados” (flushed) no disco e o commit transacional sempre deixa o banco em um estado completamente consistente. Commits ocorrem em dois passos:
1 – Todos os dados dos documentos e atualizações em índices associados são “esvaziados” (flushed) no disco de maneira síncrona.
2 – O cabeçalho do banco de dados atualizados é escrito em dois pedaços consecutivos e idênticos para compor os primeiros 4k do arquivo, então é “esvaziados” (flushed) no disco de maneira síncrona.

Caso ocorra algum erro em uma destas etapas, ambas são abortadas e o estado anterior do documento é recuperado, o que garante as propriedades ACID dos dados.


## Disponibilidade


## Escalabilidade



---
## Recomendação de estudo e organização:

Esta seção é temporária e será removida após a revisão e versão final do tutorial.

* IMPORTANTE: Especificar a versão do software utilizada para criar o tutorial!
* Introdução: instalação e configuração do cluster, visão geral e comandos básicos.
* Arquiteturas de distribuição de dados e replicação.
* Implementação de propriedades: 
* Consistência (por exemplo: implementa conceitos relacionados ao quorum?, implementa vector clocks e version vectors?)
    Fonte: https://docs.couchdb.org/en/stable/cluster/sharding.html#quorum
* Transações (é ACID em qual granularidade dos dados?)
    Fonte: https://docs.couchdb.org/en/stable/intro/overview.html#acid-properties
* Disponibilidade
* Escalabilidade
* Quando usar? Exponha como empresas estão usando esse software!
* Quando não usar?

Podem ser incluídos conceitos relacionados a estas propriedades encontrados na documentação do sistema, mesmo não vistos em sala de aula. 
A proposta acima pode ser modificada e estendida.

Usem o material das aulas sobre implementação de propriedades no mongoDB, neo4j, etc. como guia para elaboração do projeto.
