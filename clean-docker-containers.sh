#!/bin/bash
set -ex
######################################################################
#Script removing all docker containers and images installed on server#
######################################################################

# Stop all docker containers
docker kill $(docker ps -q)

# Delete all docker containers
docker rm $(docker ps -a -q)

# Remove all docker images
docker rmi $(docker images -q)

echo
echo "Docker Containers and Images deleted from $(hostname) server"
