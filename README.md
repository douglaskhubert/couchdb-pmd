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
    * [Quando usar o CouchDB?](#quandousar)
* [Instalação](#instalacao)
    * [Docker](#docker)
    * [Docker-Compose](#docker-compose)
* [Terminologia](#terminologia)
* [Configuração Básica](#configuracao-basica)
* [Comandos Básicos](#comandos-basicos)
    * [Inserindo um registro (POST)](#comandos-basicos-insert)
    * [Visualizando todos os registros (GET)](#comandos-basicos-getall)
    * [Visualizando um registro em específico (GET)](#comandos-basicos-get)
    * [Atualizando um registro (PUT)](#comandos-basicos-update)
    * [Deletando um registro (DELETE)](#comandos-basicos-delete)
    * [Map Reduce, Views e Mango](#map-reduce)
* [Implementação de Propriedades](#implementacao-propriedades)
    * [Teorema CAP](#cap)
    * [Transações e propriedades ACID/BASE](#acid)
    * [Consistência de Dados](#acid-consistencia)
    * [Quorum](#Quorum)
    * [Disponibilidade](#disponibilidade)
    * [Escalabilidade](#escalabilidade)
* [Replicação de dados no CouchDB](#replicacao)
    * [Tipos de Replicação](#tipos-replicacao)
    * [MapReduce em CouchDB? Faz sentido?](#mapreduce)
    * [Balanceamento de Carga (Loadbalancing)](#loadbalance)
    * [Particionamento de dados (sharding)](#sharding)
* [Praticando com CouchDB](#praticando)
    * Criando o nosso cluster
        * Docker-Compose (localmente)
        * Google Cloud Platform (ambiente núvem)
    * ...
    * Brincando com *queries* e verbos HTTP
        * Inserindo registros
        * Consultando registros
        * Atualizando registros


# <a name="introducao"></a>Introdução
O CouchDB é um banco de dados open source desenvolvido pela Apache™
[orientado à documentos](https://pt.wikipedia.org/wiki/Banco_de_dados_orientado_a_documentos).
O CouchDB utiliza nativamente **json** para armazenamento de dados, **JavaScript**
para sua query language, incluindo features como MapReduce e view configuration.

Por padrão, o CouchDB também suporta implementações com **RESTful API's**
(e requests via curl, por exemplo), sendo uma alternativa para implementações
diretas e agnósticas, devido à independência de qualquer necessidade de driver
ou lib para consumir e utilizar o banco.

A título de curiosidade, o nome Couch é um acrônimo para “Cluster of
Unreliable Commodity Hardware”, ou seja, cluster para máquinas de baixo poder
computacional.


# <a name="quandousar"></a> Quando usar o CouchDB?

Se as pessoas envolvidas em seu projeto já possuem um conhecimento sólido em
tecnologias web, como consumo de API's REST, a curva de aprendizagem para o CouchDB
deverá ser bem tranquila.

Devido ao fato de o CouchDB ser um banco de dados orientado à documentos, também
pode ser indicado para casos de uso onde existe a necessidade de dados *schemaless*,
em outras palavras, quando os dados podem ter diferentes estruturas e tipos.

Existem vários fatores para a escolha de um banco de dados para um projeto, não falaremos
de todos aqui, mas alguns pontos que devem ser observados é o comportamento e a forma que
o banco de dados em questão implementa as propriedades ACID, qual sua posição referente
ao teorema CAP, qual propriedade do teorema o banco de dados escolhe relaxar, entre
outros conceitos que apresentamos nesta parte teórica do tutorial.


# <a name="instalacao"></a>Instalação

Vamos mostrar como realizar a instalação do CouchDB utilizando Docker e
Docker-Compose.

Requisitos:
* macOS ou Linux;
* Docker;

Opcional:
* Docker-Compose

## <a name="docker"></a> Docker

Uma vez com o docker instalado e apropriadamente configurado, basta instalar a
[imagem disponibilizada do CouchDB no hub do docker](https://hub.docker.com/_/couchdb):

```
$ docker pull couchdb:2.3.1
$ docker run -p 5984:5984 -d couchdb
```
Uma vez rodado ambos comandos, o Docker subirá uma instância do CouchDB.

Por padrão, o CouchDB roda na porta 5984, neste caso, com a flag **-p**
estamos expondo esta porta do container em nossa máquina/rede.

A versão utilizada neste tutorial foi a latest, que até o presente dia
(22/10/2019) é listada como a *latest* do repositório.

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

PS: Caso deseje parar o container do docker, basta suspender o container com
sua id
```
$ docker stop <container_id>
```

## <a name="docker-compose"></a>Docker-Compose

A utilização do docker-compose é opcional, porém essa ferramenta facilitará
bastante a nossa vida na hora de nossos exercícios práticos com um cluster de
instâncias CouchDB.
A partir de um único arquivo conseguimos subir todas as instâncias com seus
respectivos arquivos de configuração.

Crie um arquivo chamado docker-compose.yaml e coloque o seguinte conteúdo
dentro:

```yaml
version: "3.0"
services:
  couchdb:
    image: couchdb:2.3.1
    ports:
      - 5984:5984
```

Vamos incrementar esse arquivo quando falarmos sobre replicação de dados e
sharding.

Para iniciar nosso servidor CouchDB, digite o comando:

```
$ docker-compose up
```

Aguarde o download da imagem e pronto.

Para validar se a instância está rodando localmente e operante, basta executar:
```
$ curl http://127.0.0.1:5984/
```

# <a name="terminologia"></a>Terminologia

Há uma certa semelhança entre os termos do **CouchDB** e o **MongoDB**, confira abaixo as terminologias:

CouchDB | MongoDB | RDBMS
--- | --- | ---
 Database | Database | Database
Document | Collection | Table
" | Document | Row
Index | Index | Index
Value | Field | Column
MapReduce/Views | MapReduce & Aggreagation | Join

Por padrão, o CouchDB tem uma database composta de vários documentos, sendo essencialmente diferente dos casos de um RDBMS tradicional ou mesmo o MongoDB - que cada coleção organiza seus próprios documentos e há uma junção de documentos dentro de uma mesma coleçao.

Além disso, o CouchDB explora muito o padrão de queries para otimização e refinamento - queries que são frequentemente utilizadas ou mesmo estão distribuídas em diversos clusters exigem a criação de uma View por padrão. Uma View pode ser composta de funções Map e Reduce em JavaScript nativo - muito semelhante ao abordado no MongoDB.


# <a name="configuracao-basica"></a>Configuração Básica

É possível configurar e utilizar o CouchDB através de duas maneiras:
* **API** - Nativa;
* Interface/Browser via **Fauxton**(antigo Futon)

Na primeira execução, o Couch rodará no chamado *admin-party mode*, no qual
não há um admnistrador definido.

É possível configurar a primeira ocasião utilizando o Fauxton -
[via interface](http://127.0.0.1:5984/_utils/#/setup).
Clique no botão "Configure a Single Node" para configurar uma réplica inicial.
Neste primeiro setup, não introduziremos réplicas ou mesmo clusters, que
também são features suportadas pelo CouchDB

É necessário introduzir e configurar um admin durante o setup, utilizaremos:
**user**: admin
**password**: 1234

Uma vez configurado, esta será a autenticação utilizada para criar novos
usuários, databases, inserir dados etc. Seja via interface ou curl.

# <a name="comandos-basicos"></a>Comandos Básicos

Para criar uma database via curl, utilizaremos o seguinte padrão:

```
$ curl -X PUT http://usuario:senha@host:port/nome_database
```
Note a presença do username com criado e a senha do mesmo, bem como o host (IP)
e a porta do servidor local.

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

Perceba que todas as inputs retornam valores em formatos conhecidos - muitos
na notação JSON.

Antes de realizar inserts, é recomendável gerar *Universally Unique
Identifiers* (UUIDs) da própria instância do Couch - essa abordagem é ideal
para que não haja chaves duplicadas dentro do banco.

Retorna uma UUID:
```
$ curl -X GET http://admin:1234@127.0.0.1:5984/_uuids
```
```json
{
  "uuids":["8a2519d228e6ea9b4dcd1e7f37000976"]
}
```

É possível também retornar mais de uma chave para evitar *overflow* de
requests na API:
```
curl -X GET http://admin:1234@127.0.0.1:5984/_uuids?count=10
```
### Visualizando a DB Teste

Para utilizarmos a DB teste, basta utilizar na mesma lógica de uma API rest -
se adiciona o nome da database um pouco antes do request. Neste tópico, o
CouchDB leva vantagem sobre qualquer sistema SQL tradicional pela simplicidade.
Em um sistema SQL tradicional seria necessário criar novos clientes de conexão
em um aplicacão para se consumir mais de uma database.

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

Neste comando, é retornado os status de cluster, total de documentos, uma
purge_sequence, quantidade de documentos, tamanho em disco e informações da
instância.

Para obter **todos** documentos presentes na database *teste*:
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
### <a name="comandos-basicos-insert"></a>Inserindo um registro (PUT)

Agora, vamos inserir o seguinte documento na database **teste**:
```json
{
  "nome": "Nicolas", 
  "idade": 26,
  "notas": [5, 6, 7]
}
```
Com este documento - é possível executar um comando *HTTP* do tipo *PUT*, utilizando a mesma unique id informada  acima:
```
curl -H 'Content-Type: application/json' -X PUT http://admin:1234@127.0.0.1:5984/teste/"8a2519d228e6ea9b4dcd1e7f37000976" -d'{"nome": "Nicolas","idade": 26, "notas": [5, 6, 7]}'
```

O curl acima informa que o tipo de conteúdo do *request* será json, bem como a rota **/teste/uuid** informa a database e a id informada, respectivamente. 
Logo em seguida, há o conteúdo da mensagem que trata do objeto a ser inserido.

```json
{
  "ok":true,
  "id":"8a2519d228e6ea9b4dcd1e7f37000976",
  "rev":"1-891f8a9577b2e71fe57eccddbd26cae3"
}
```
* A chave "ok" sinaliza se houve sucesso na inserção do documento.
* A chave "id" te retorna o id do objeto criado (neste caso, o mesmo informado)
* A chave "rev" te retorna a revisão/versão do documento inserido.

### <a name="comandos-basicos-getall"></a> Visualizando todos os registros (GET)

Para visualizar os registros, toma-se como premissa sempre uma operação do tipo *GET* na database específica.
```
curl -X GET http://admin:1234@127.0.0.1:5984/teste/_all_docs
```
```json
{
  "total_rows":1,
  "offset":0,
  "rows":[{
            "id":"8a2519d228e6ea9b4dcd1e7f37000976",
            "key":"8a2519d228e6ea9b4dcd1e7f37000976",
            "value": {
                      "rev":"1-891f8a9577b2e71fe57eccddbd26cae3"
            }
          }
        ]
}
```

Neste caso, retorna-se o número total de rows, o ID de cada um dos documentos e a revisão na qual cada um se encontra.

Caso fosse desejado também incluir os dados de cada um dos documentos - é necessário sinalizar uma query adicional
```
curl -X GET http://admin:1234@127.0.0.1:5984/teste/_all_docs?include_docs=true
```

### <a name="comandos-basicos-get"></a>Visualizando um registro em específico (GET)

Para obter um documento em específico - basta-se sinalizar a id do mesmo após a database:
```
curl -X GET http://admin:1234@127.0.0.1:5984/teste/8a2519d228e6ea9b4dcd1e7f37000976
```

```json

{
  "_id":"8a2519d228e6ea9b4dcd1e7f37000976",
  "_rev":"1-891f8a9577b2e71fe57eccddbd26cae3",
  "nome":"Nicolas",
  "idade":26,
  "notas":[5,6,7]
}
```

Observa-se a presença de um campo chave para a estrutura normal do CouchDB - o número da revisão (*_rev*), que é um registro necessário para todas as operações.


### <a name="comandos-basicos-update"></a>Atualizando um registro (PUT)

Para atualizar um registro, é necessário especificar duas coisas:
* ID do registro;
* ID da revisão a ser atualizada;


```
curl -H 'Content-Type: application/json' -X PUT http://admin:1234@127.0.0.1:5984/teste/"8a2519d228e6ea9b4dcd1e7f37000976" -d'{"nome": "Nicolas","idade": 27, "notas": [9, 9, 10], "_rev": "1-891f8a9577b2e71fe57eccddbd26cae3"}' 
```
Por gentileza notar o atributo *_rev* informado, que especifica qual versão está sendo atualizada.
Por fim - o CouchDB retorna o status, o ID do registro atualizado e o novo ID da revisão, neste caso, iniciada com o prefixo **2-**, que indica que o documentose encontra na segunda versão.

```json
{
  "ok":true,
  "id":"8a2519d228e6ea9b4dcd1e7f37000976",
  "rev":"2-e374d0fcab5b47ab0a2a04178fc274c3"
}
```

Caso fossemos checar novamente este registro, obteríamos o seguinte tópico:

```
curl -X GET http://admin:1234@127.0.0.1:5984/teste/8a2519d228e6ea9b4dcd1e7f37000976
```

```json
{
  "_id":"8a2519d228e6ea9b4dcd1e7f37000976",
  "_rev":"2-e374d0fcab5b47ab0a2a04178fc274c3",
  "nome":"Nicolas",
  "idade":27,
  "notas":[9,9,10]
}
```

É possível atualiar os registros continuamente, entretanto, toda operação de update performar um overwrite em todo o registro.

Na ocasião, um curl do tipo:
```
curl -H 'Content-Type: application/json' -X PUT http://admin:1234@127.0.0.1:5984/teste/"8a2519d228e6ea9b4dcd1e7f37000976" -d'{"idade": 28, "_rev": "2-e374d0fcab5b47ab0a2a04178fc274c3"}'
```
Atualizaria o registro para o seguinte:

```json
{
  "_id":"8a2519d228e6ea9b4dcd1e7f37000976",
  "_rev":"3-6560152a526f93bab04c5d3b6446777e",
  "idade":28
}
```
Se, hipoteticamente, algum outro cliente tentasse atualizar o registro da database no mesmo momento - utilizando o ID da segunda revisão (_rev: 2-...).
```
curl -H 'Content-Type: application/json' -X PUT http://admin:1234@127.0.0.1:5984/teste/"8a2519d228e6ea9b4dcd1e7f37000976" -d'{"idade": 28,"aprovado": true, "_rev": "2-e374d0fcab5b47ab0a2a04178fc274c3"}'
```
O cliente apontaria o seguinte:
```json
{
  "error":"conflict",
  "reason":"Document update conflict."
}
```
Pois a revisão especificada do documento não é a última/mais recente.


### <a name="comandos-basicos-delete"></a>Deletando um registro (DELETE)

Como de praxe, para deletar um registro no CouchDB, basta realizar uma operação do tipo **DELETE**. Entretanto devido a natureza do CouchDB, não é possível simplesmente deletar os arquivos informando somente a ID, as operações de DELETE também necessitam do parâmetro de revisão - para que se haja consistência durante a operação.
```
curl -X DELETE http://admin:1234@127.0.0.1:5984/teste/8a2519d228e6ea9b4dcd1e7f37000976\?rev\=4-6d74341cddb1dfb648e6d459764b8d55
```
O retorno do CouchDB indica basicamente que o registro foi deletado, e também é gerado um número de revisão novo.
```json
{
  "ok":true,
  "id":"8a2519d228e6ea9b4dcd1e7f37000976",
  "rev":"5-408bcf8c726e71091890cfe06bb7756d"
}
```
 Os registros no CouchDB nunca deixam de existir, somente são ocultados de todas as queries e views.

 Na ocorrência de uma busca por esta ID, o CouchDB informa que este registro foi deletado:
```json
{
  "error":"not_found",
  "reason":"deleted"
}
```


### <a name="map-reduce"></a>Map Reduce, Views e Mango

O CouchDB também implementa queries de filtro - à partir da versão 2.0 do CouchDB, há duas opções para os que desejam filtrar algum resultado:
* Criar uma *View* (Função JavaScript) - que implemente um Map, contendo ou não o Reduce;
* Filtrar via *Mango Query*;

No geral, o CouchDB atualmente recomenda  utilizar os filtros, por padrão, com o Mango. Ainda assim - ambas situações exigem um post na específica DB a ser obtida.

```json
curl -H 'Content-Type: application/json' -X PUT http://admin:1234@127.0.0.1:5984/teste/_find " -d'{
    "selector": {
        "idade": {"$gt": 20}
    },
    "limit": 2,
    "skip": 0,
    "execution_stats": true
}
```
**indentação quebrada para facilitar a leitura*

* **selector**: Filtro com as condicionais - muito semelhante ao padrão encontrado no mongo.
* **limit**: Quantos documentos (no total) serão exibidos;
* **skip**: Quantos documentos (dos primeiros) serão pulados;
* **execution_stats**: Retorna as estatísticas da query (performance);

Nota-se também a presença de uma operação do tipo POST pela primeira vez - muito utilizada para setup de alguns tópicos pontuais do couch, bem como os filtros mango

# <a name="implementacao-propriedades"></a> Implementação de Propriedades no CouchDB

Nesta parte do tutorial, vamos falar um pouco sobre como o CouchDB implementa propriedades
relacionadas à banco de dados.

## <a name="cap"></a> Teorema CAP

O [teorema CAP](https://en.wikipedia.org/wiki/CAP_theorem) afirma que em um
sistema de armazenamento de dados distribuído não podemos prover simultâneamente
3 das seguintes garantias: **C**onsistência, Disponibilidade (**A**vailability) e 
tolerância a **P**articionamento.

Existem sistemas que nunca podem ficar offline, portanto, não desejam sacrificar a 
disponibilidade. Para ter alta disponibilidade mesmo com tolerância a particionamento 
é preciso prejudicar a consistência. Aqui, a ideia é que os sistemas aceitem escritas 
e sincronizem os dados depois.

O CouchDB se encaixa em algum lugar entre Disponibilidade e Tolerância a
particionamento, o que significa que sua **consistência** é **eventual**, ou seja,
mais cedo ou mais tarde, o banco de dados estará consistente.

<p align="center">
  <img width="451" height="388" src="static/cap-theorem-couchdb.png?raw=true">
  <br>
  <i style="font-size: 14px">fonte: https://docs.couchdb.org/en/stable/intro/consistency.html#the-cap-theorem</i>
</p>

## <a name="acid"></a> Transações e propriedades ACID/BASE

Tanto o layout de arquivos como o sistema de confirmação de gravação do CouchDB implementam 
todas as [propriedades ACID](https://en.wikipedia.org/wiki/ACID) (atomicidade, consistência, 
isolamento e durabilidade). Como são geradas sempre novas versões 
do documento, muito similar ao modo como funcionam as ferramentas de controle de
versão ([Git](https://git-scm.com/), por exemplo), os documentos não ficam travados e
principalmente, com o estado consistente. Alterações nos documentos (adicionar,
editar, deletar) são serializadas, exceto os [blobs binários](https://en.wikipedia.org/wiki/Binary_large_object)
que são escritos concorrentemente. Leituras no banco nunca são bloqueadas (lock) e nunca tem
que esperar por escritas ou outras leituras. Os documentos são indexados em b-
trees [B-tree](https://en.wikipedia.org/wiki/B-tree) pelo seu nome (DocID) e um ID de sequência. 
Cada atualização para uma instância de banco de dados gera um novo número sequencial. 
IDs de sequência são usados depois para encontrar as mudanças de forma incremental em uma base
de dados. Esses índices b-trees (árvores B) são atualizados simultaneamente
quando os documentos são salvos ou deletados.

Quando os documentos do CouchDB são atualizados, todos os dados e índices
associados são “descarregados” (flushed) no disco e o *commit* transacional
sempre deixa o banco em um estado completamente consistente. *Commits* ocorrem
em dois passos:
1. Todos os dados dos documentos e atualizações em índices associados são “
esvaziados” (flushed) no disco de maneira síncrona.
2. O cabeçalho do banco de dados atualizados é escrito em dois pedaços
consecutivos e idênticos para compor os primeiros 4k do arquivo, então é “
esvaziados” (flushed) no disco de maneira síncrona.

Caso ocorra algum erro em uma destas etapas, ambas são abortadas e o estado
anterior do documento é recuperado, o que garante as propriedades ACID dos
dados.

Já quanto a propriedade BASE, definida pelo cientista [Eric Brewer](https://en.wikipedia.org/wiki/Eric_Brewer_%28scientist%29), é fácil identificar que o CouchDB também se encaixa muito bem, como a grande maioria 
dos bancos NoSQL, pois prima pela disponibilidade, garantindo a consistência 
dos dados de forma assíncrona a gravação destes mesmos dados. Vale lembrar 
que a propriedade BASE prega
BA – (Basically Available) – Disponibilidade é prioridade.
S – (Soft-State) – Não precisa ser consistente o tempo todo.
E – (Eventually Consistent) – Consistente em momento indeterminado.

<p align="center">
  <img width="572" height="227" src="static/ACIDxBASE.png?raw=true">
</p>


### <a name="acid-consistencia"></a> Consistência
O CouchDB faz uso de Controle de Concorrência de Múltiplas Versões ou somente
[MVCC](https://en.wikipedia.org/wiki/Multiversion_concurrency_control#Implementation)
(Multiversion Concurrency Control), o que permite que diversos acessos
sejam feitos ao mesmo dado de forma simultânea, sendo assim, teremos uma
disponibilidade dos dados bastante expressiva e com isso, alta escalabilidade.

<p align="center">
  <img width="636" height="209" src="static/recordlock.png?raw=true">
</p>

Sempre que um usuário queira realizar uma alterção nos dados, estes dados não
serão bloqueados aos demais usuários do banco, porém será disponibilizada uma
versão anterior dos dados, o que caracteriza a **consistência eventual** usando
replicação incremental presente no CouchDB. O sistema de replicação do CouchDB
vem com detecção e resolução automáticas de conflitos. Quando o CouchDB
detecta que um documento foi alterado em dois bancos de dados, sinaliza esse
documento como estando em conflito, como se estivessem em um sistema de
controle de versão regular.


### <a name="Quorum"></a> Quorum

Quando falamos de sistemas distribuídos, normalmente temos alguns tipos de problemas
que são chamados de ["problemas de consenso"](https://pt.wikipedia.org/wiki/Consenso_Distribu%C3%ADdo),
quando falamos de consenso, também estamos falando de garantir a confiabilidade
do sistema, no nosso caso, de leituras e escritas. Uma solução bastante conhecida
para isso é o [quorum](https://en.wikipedia.org/wiki/Quorum_(distributed_computing)).
No nosso caso, queremos um quorum de leitura e escrita para garantir que todos
os nós cheguem em um consenso sobre o que ler e o que escrever.  O CouchDB já
tem uma fórmula de quorum nativa: um mais metade do número de "cópias
relevantes". As cópias relevantes são definidas diferentemente para leitura e
escrita.

Para **leitura**, o CouchDB considera esse número de "cópias relevantes" como o número
de nós acessíveis do dado que foi requisitado. Por exemplo, se um usuário realiza
um *request* para visualizar um determinado pedido de um cliente, e este pedido
está replicado em 6 nós, mas apenas 4 nós estão ativos, o quorum é formado por esses
4 nós. O número de cópias de leitura pode ser customizado pelo parâmetro **r**


### <a name="disponibilidade"></a> Disponibilidade
O CouchDB foi idealizado para que houvesse uma alta disponibilidade sem 
bloqueios para que fosse possível atendem sistemas de alto consumo de dados.
Para ser possível atender essa necessidade de alta disponibilidade, o CouchDB
trabalha com um conceito onde de certa forma "nada é compartilhado", mas sim 
replicado para os demais nós do cluster. Isso faz com que, mesmo que um nó 
apresente alguma falha momentânea, os demais nós continuarão a trabalhar de
forma independente garantindo uma alta disponibilidade, com confiabilidade e
eficiência.


### <a name="escalabilidade"></a> Escalabilidade
Como na maioria dos bancos de dados NoSQL, o CouchDB trabalha muito bem com o 
conceito de escalabilidade horizontal. É possível escalar o banco de dados a 
partir do aumento de máquinas disponíveis para o seu processamento, 
diferentemente dos bancos de dados relacionais que não trabalham muito bem com
a escalabilidade horizontal em função da concorrência.

Outro fator muito importante para o CouchDB permitir escalabilidade horizontal
é o fato de não haver locks de registros além de possuir um esquema de dados
flexível, ou até mesmo pode se dizer que não há esquema de dados, e com isso,
não é necessário garantir a persistência dos dados em tabelas diferentes. 
Todos estes fatores, aliados ao processo de replicação que será visto a seguir,
fazem com que o CouchDB seja considerado um banco de dados bastante escalável
se adaptando com facilidade as mais diferentes necessidades.


## <a name="replicacao"></a> Replicação
O CouchDB trabalha com replicação no conceito Mestre-Mestre onde o CouchDB
comparará o banco de dados de origem e destino para determinar quais
documentos diferem entre o banco de dados de origem e destino. Isso é feito
seguindo os Feeds de alterações na origem e comparando os documentos com o
destino. As alterações são enviadas para o destino em lotes onde eles podem
introduzir conflitos. Os documentos que já existem no destino na mesma revisão
não são transferidos. Como a exclusão de documentos é representada por uma
nova revisão, um documento excluído na fonte também será excluído no
destino.

Uma tarefa de replicação será concluída assim que chegar ao final do feed de
alterações. Se sua propriedade contínua estiver configurada como true,
aguardará a exibição de novas alterações até que a tarefa seja cancelada. As
tarefas de replicação também criam documentos de ponto de verificação no
destino para garantir que uma tarefa reiniciada possa continuar de onde parou,
por exemplo, após a falha.

<p align="center">
  <img width="416" height="264" src="static/Replication.png?raw=true">
</p>


## <a name="loadbalance"></a> Balanceamento de Carga (Loadbalancing)
O CouchDB trabalha com API HTTP para receber suas requisições, então é possível usar 
qualquer solução de mercado para fazer o balanceamento de carga do CouchDB, como por 
exemplo o [NGInx](https://pt.wikipedia.org/wiki/Nginx).
Outra forma de se realizar o balanceamento de carga é elegendo um nó específico para 
as operações de escrita ( POST, PUT, DELETE, MOVE, e COPY) e alguns nós diferentes 
para realizar as operações de leitura ( GET, HEAD e OPTIONS).

<p align="center">
  <img width="474" height="391" src="static/LoadBalance.jpg?raw=true">
</p>


## <a name="sharding"></a> Particionamento de dados (sharding)
Sharding nada mais é do que um banco de dados particionado de forma horizontal. Quando é 
feito o sharding, os dados são replicados para diferentes nós de um cluster, o que garante
maior segurança contra a perda de nós, e consequentemente dados. 
O CouchDB já executa o sharding de forma automatica entre os nós do cluster
A quantidade de shards e réplicas podem ser definidas globalmente ou específicas para cada
banco de dados e seus parâmetros de consiguração são "q" (shards) e "n" (réplicas). Os valores
padrão são 8 shards (q=8) e 3 réplicas (n=3). Seguindo os valores definidos como padrão, haverá
24 partes de um único banco de dados espalhado pelo cluster. Uma boa prática é que o número de
nós de um banco de dados seja multipo da quantidade de partes do banco, ou seja, se há 24 partes, 
o correto seria haver 2 ou 3 ou 4 ou 6 ou 8 nós configurados.


# <a name="praticando"></a> Praticando com CouchDB

Nesta parte do tutorial, vamos mostrar como montar um cluster de instâncias
de CouchDB.

### Configurando os nós para nosso cluster



Vamos definir que nosso cluster terá um número **q** de shards, que é a quantidade
de nós em que o CouchDB vai particionar nossos dados e um número n de réplicas,
que é a quantidade de cópias que cada dado terá. Portanto, para este tutorial,
teremos que **q = 9** e **n = 3**, o que significa que nossos dados ficarão
particionados em 9 partes em 3 nós, respectivamente.

Primeiramente, vamos criar os arquivos de configuração para nosso cluster na
seguinte estrutura de pasta:
```
.
├── docker-compose.yaml
├── node1
│   └── config
│       └── vm.args
├── node2
│   └── config
│       └── vm.args
├── node3
│   └── config
│       └── vm.args
└── shared
    ├── docker.ini
    └── local.ini
```

Crie o  diretório raíz chamado cluster-couchdb:

```
$ mkdir cluster-couchdb
$ cd cluster-couchdb
```

Crie o arquivo **docker-compose.yaml**, para podemos inicializar os containers de forma
declarativa:
```
version: "3.0"
services:
  couchdb1:
    image: couchdb:2.3.1
    expose:
      - 5984
    volumes:
      - ./node1/config/vm.args:/opt/couchdb/etc/vm.args
      - ./shared/local.ini:/opt/couchdb/etc/local.ini
      - ./shared/docker.ini:/opt/couchdb/etc/local.d/docker.ini

  couchdb2:
    image: couchdb:2.3.1
    expose:
      - 5984
    volumes:
      - ./node2/config/vm.args:/opt/couchdb/etc/vm.args
      - ./shared/local.ini:/opt/couchdb/etc/local.ini
      - ./shared/docker.ini:/opt/couchdb/etc/local.d/docker.ini

  couchdb3:
    image: couchdb:2.3.1
    expose:
      - 5984
    volumes:
      - ./node3/config/vm.args:/opt/couchdb/etc/vm.args
      - ./shared/local.ini:/opt/couchdb/etc/local.ini
      - ./shared/docker.ini:/opt/couchdb/etc/local.d/docker.ini

```

```
#node1/config/vm.args
# Ensure that the Erlang VM listens on a known port
-kernel inet_dist_listen_min 9100
-kernel inet_dist_listen_max 9100

# Tell kernel and SASL not to log anything
-kernel error_logger silent
-sasl sasl_error_logger false

# Use kernel poll functionality if supported by emulator
+K true

# Start a pool of asynchronous IO threads
+A 16

# Comment this line out to enable the interactive Erlang shell on startup
+Bd -noinput

# Node's name in network
-name couchdb@couchdb1
```

Graças ao dns interno do docker-compose, conseguimos usar o nome do serviço
como host na configuração "-name couchdb@***couchdb1***"

Crie o mesmo arquivo **vm.args** para os diretórios `node2/config/vm.args` e
`node3/config/vm.args` mudando apenas o nome dos *hosts* para que correspondam
ao nome do serviço no docker-compose, no nosso caso `couchdb2` e `couchdb3`.

Em caso de dúvidas referente a estrutura das pastas e/ou conteúdo dos arquivos,
você pode consultar o [repositório](https://github.com/douglaskhubert/couchdb-pmd/tree/master/cluster-couchdb)
deste tutorial no GitHub.

Então, nossos arquivos de vm.args estão nos dizendo que os nós do cluster possuem
os seguintes nomes:

* Nó 1: couchdb1
* Nó 2: couchdb2
* Nó 3: couchdb3

E o usuário para acessar o host via cluster nos três nós é ***couchdb***. Vamos
utilizar essa informação daqui a pouco.

Agora vá até a raiz do projeto e inicialize os serviços executando o comando:

```
$ docker-compose up
```

Será exibido o seguinte:
```
 $ docker-compose up
Creating network "cluster-couchdb_default" with the default driver
Creating cluster-couchdb_couchdb3_1 ... done
Creating cluster-couchdb_couchdb1_1 ... done
Creating cluster-couchdb_couchdb2_1 ... done
Attaching to cluster-couchdb_couchdb1_1, cluster-couchdb_couchdb3_1, cluster-couchdb_couchdb2_1
```

Aguarde alguns minutos para a inicialização dos 3 nós, quando tudo estiver pronto,
começaremos a ver algumas saídas de logs.

### Ingressando os nós no cluster via Fauxton

Após subirmos os 3 nós do cluster, vamos pegar o ip de um deles:
```
 $ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                          NAMES
cc1a8732ec12        couchdb:2.3.1       "tini -- /docker-ent…"   6 minutes ago       Up 6 minutes        4369/tcp, 5984/tcp, 9100/tcp   cluster-couchdb_couchdb1_1
1c4261efbad7        couchdb:2.3.1       "tini -- /docker-ent…"   6 minutes ago       Up 6 minutes        4369/tcp, 5984/tcp, 9100/tcp   cluster-couchdb_couchdb3_1
d355517b12f2        couchdb:2.3.1       "tini -- /docker-ent…"   6 minutes ago       Up 6 minutes        4369/tcp, 5984/tcp, 9100/tcp   cluster-couchdb_couchdb2_1
 $ docker inspect cluster-couchdb_couchdb1_1
 ...
"IPAddress": "172.21.0.3",
 ...
```

Acesse o ip do container na porta 5984 via navegador web: 
http://172.21.0.3:5984/\_utils#setup, no nosso caso.

Faça login com usuário **admin** e senha **mysecretpassword**.

Va para a url **/\_utils/#setup/multinode** clicando no ícone da chave inglesa e
depois em "Configure a Cluster".

<p align="center">
  <img width="451" height="388" src="static/configure-cluster.jpeg?raw=true">
</p>

Vamos configurar o nosso nó base, preencha os campos da seguinte forma:

* **Username:** admin
* **Password:** mysecretpassword
* **Bind address the node will listen on:** 172.21.0.3
* **Port that the node will use:** 5984
* **Number of nodes to be added to the cluster (including this one):** 3

Agora vamos adicionar os outros 2 nós. Preencha primeiramente da seguinte forma:

* **Remote host:** couchdb@couchdb2
* **Bind address the node will listen on:** 172.21.0.2
    * Pegue esse ip da mesma forma que pegamos anteriormente
* **Port that the node will use:** 5984

Clique em Add Node.

Preencha com os dados para o nó 3:

* **Remote host:** couchdb@couchdb3
* **Bind address the node will listen on:** 172.21.0.4
    * Pegue esse ip da mesma forma que pegamos anteriormente
* **Port that the node will use:** 5984

Clique em Add Node.

Por fim, clique em "Configure Cluster".

Pronto, nossos nós estão no cluster, para conferir, acesse:

---
### Recomendação de estudo e organização:

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
