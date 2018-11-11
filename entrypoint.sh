#!/bin/bash

set -u # Fail on unset variables
set -e # Fail if any command fails
#get container IP from the container metadata
CONTAINER_IP=$(curl -s http://169.254.170.2/v2/metadata | jq -r .Containers[0].Networks[0].IPv4Addresses[0])
PORT_OFFSET=0
echo "Using Container IP: ${CONTAINER_IP}"
echo "Using Port Offset: ${PORT_OFFSET} "
#Bind Wildfly interfaces to the container IP. The port offset allows Wildfly interfaces to be started on different ports.
exec /opt/jboss/wildfly/bin/standalone.sh -c standalone-ha.xml -b ${CONTAINER_IP} -bmanagement ${CONTAINER_IP} -Djboss.node.name=node-${CONTAINER_IP} -Djboss.bind.address.private=${CONTAINER_IP} -Djboss.socket.binding.port-offset=${PORT_OFFSET}

