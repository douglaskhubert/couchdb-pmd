#!/bin/bash -x
# First, get two UUIDs to use later on. Be sure to use the SAME UUIDs on all nodes.

MODE="MANUAL"

function wait {
    if [ $MODE = "MANUAL" ]; then
        read
    fi
}

HOST1=admin:mysecretpassword@$(docker inspect cluster-couchdb_couchdb1_1 | jq -r '.[].NetworkSettings.Networks | .[].IPAddress'):5984
HOST2=admin:mysecretpassword@$(docker inspect cluster-couchdb_couchdb2_1 | jq -r '.[].NetworkSettings.Networks | .[].IPAddress'):5984
HOST3=admin:mysecretpassword@$(docker inspect cluster-couchdb_couchdb3_1 | jq -r '.[].NetworkSettings.Networks | .[].IPAddress'):5984

UUID1=$(curl "$HOST1"/_uuids?count=1 | jq -r .uuids[0])
UUID2=$(curl "$HOST1"/_uuids?count=1 | jq -r .uuids[0])

# Now, bind the clustered interface to all IP addresses availble on this machine
curl -D - -X PUT $HOST1/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'
wait
# Set the UUID of the node to the first UUID you previously obtained:
curl -D - -X PUT $HOST1/_node/_local/_config/couchdb/uuid -d '"'$UUID1'"'
wait
# Finally, set the shared http secret for cookie creation to the second UUID:
curl -D - -X PUT $HOST1/_node/_local/_config/couch_httpd_auth/secret -d '"'$UUID2'"'
wait


# Now, bind the clustered interface to all IP addresses availble on this machine
curl -D - -X PUT $HOST2/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'
wait
# Set the UUID of the node to the first UUID you previously obtained:
curl -D - -X PUT $HOST2/_node/_local/_config/couchdb/uuid -d '"'$UUID1'"'
wait
# Finally, set the shared http secret for cookie creation to the second UUID:
curl -D - -X PUT $HOST2/_node/_local/_config/couch_httpd_auth/secret -d '"'$UUID2'"'
wait


# Now, bind the clustered interface to all IP addresses availble on this machine
curl -D - -X PUT $HOST3/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'
wait
# Set the UUID of the node to the first UUID you previously obtained:
curl -D - -X PUT $HOST3/_node/_local/_config/couchdb/uuid -d '"'$UUID1'"'
wait
# Finally, set the shared http secret for cookie creation to the second UUID:
curl -D - -X PUT $HOST3/_node/_local/_config/couch_httpd_auth/secret -d '"'$UUID2'"'


curl -D - -X POST -H "Content-Type: application/json" $HOST1/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"mysecretpassword", "node_count":"3"}'
wait
curl -D - -X POST -H "Content-Type: application/json" $HOST2/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"mysecretpassword", "node_count":"3"}'
wait
curl -D - -X POST -H "Content-Type: application/json" $HOST3/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"mysecretpassword", "node_count":"3"}'
wait



# Add nodes into cluster through HOST1
curl -D - -X POST -H "Content-Type: application/json" $HOST1/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"mysecretpassword", "port": 5984, "node_count": "3", "remote_node": "couchdb2.couchnet", "remote_current_user": "admin", "remote_current_password": "mysecretpassword" }'
wait
curl -D - -X POST -H "Content-Type: application/json" $HOST1/_cluster_setup -d '{"action": "add_node", "host":"couchdb2.couchnet", "port": 5984, "username": "admin", "password":"mysecretpassword"}'
wait

curl -D - -X POST -H "Content-Type: application/json" $HOST1/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"mysecretpassword", "port": 5984, "node_count": "3", "remote_node": "couchdb3.couchnet", "remote_current_user": "admin", "remote_current_password": "mysecretpassword" }'
wait
curl -D - -X POST -H "Content-Type: application/json" $HOST1/_cluster_setup -d '{"action": "add_node", "host":"couchdb3.couchnet", "port": 5984, "username": "admin", "password":"mysecretpassword"}'
wait

curl -D - -X POST -H "Content-Type: application/json" $HOST1/_cluster_setup -d '{"action": "finish_cluster"}'
wait

curl -D - $HOST1/_membership
wait
