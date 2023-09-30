#!/bin/sh

echo "Environment substitution with /ptm/server_variables.json to /pgadmin4/servers.json"
envsubst < /ptm/servers_variables.json > /pgadmin4/servers.json
echo "Launching default entrypoint"
sh /entrypoint.sh