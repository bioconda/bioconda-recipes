#!/bin/bash

docker ps 2>&1
if [ $? -ne 0 ] ; then
  # we can't run this test, assumed everything is going to be fine
  exit 0
fi 

docker run -p 7474:7474 -e NEO4J_AUTH=none --rm --name neo4jdb.$$ neo4j:2.3 &
DOCKER_PID=$!

sleep 30

python -c 'import neomodel' 
EXIT_STATUS=$?

kill $DOCKER_PID

exit $EXIT_STATUS
