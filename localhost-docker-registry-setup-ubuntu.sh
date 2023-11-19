#!/bin/bash
set -ex
############################################################################################################
# Script setup localhost docker image registry on ubuntu server using docker-compose                       #
# https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-20-04 #
############################################################################################################
export DOCKER_REGISTRY_LOCAL_DIR=$1

# Validate argument entered for docker registry local directory
if [[ -z ${DOCKER_REGISTRY_LOCAL_DIR} ]]
then
  echo "USAGE: bash `basename $0` ~/docker_images \n"
  exit 1
fi

# Validate Docker registry image loaded to server
if [[ -z `docker images | grep registry` ]]
then
  echo "Docker registry image NOT FOUND on server, please pull/load it first and re-run"
  echo "e.g. - docker pull registry:2 or docker load -i ./docker-registry-2.tar.gz"
  exit 1
fi

# Create local data directory
mkdir -p ${DOCKER_REGISTRY_LOCAL_DIR}/data

# Create docker compose file
cat > ${DOCKER_REGISTRY_LOCAL_DIR}/docker-compose.yml << EOF
version: '3'

services:
  registry:
    image: registry:2
    ports:
    - "5000:5000"
    environment:
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
    volumes:
      - ./data:/data
EOF

# Start docker container for docker registry
cd ${DOCKER_REGISTRY_LOCAL_DIR}
docker-compose up -d

# Validate docker registry container is running
if [[ ! -z `docker images | grep registry` ]]
then
  echo "localhost docker registry configure succesfully and its container running on `hostname` "
fi
