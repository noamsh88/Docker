#!/bin/bash
set -evx
##########################################################################
# Script configure docker image repository url at docker insecure registry
# default config file path: /etc/docker/daemon.json
##########################################################################
export INSECURE_DOCKER_REPO_URL=$1

# Script Configurations
export DOCKER_DAEMON_FILE=/etc/docker/daemon.json

# Validate argument for INSECURE_DOCKER_REPO_URL entered
if [[ -z ${INSECURE_DOCKER_REPO_URL} ]]
then
  echo "\n USAGE : `basename $0` <Insecure docker repository URL> "
  echo "\n Example: bash `basename $0` 10.1.1.22:8080  \n "
  exit 1
fi

# Validate if docker repo url exist already on /etc/docker/daemon.json
export REPO_EXISTS=`grep -i "${INSECURE_DOCKER_REPO_URL}" /etc/docker/daemon.json`
if [[ ! -z ${REPO_EXISTS} ]]
then
  echo "${INSECURE_DOCKER_REPO_URL} Docker Images Repository is already configured on ${DOCKER_DAEMON_FILE} , exiting.."
  cat ${DOCKER_DAEMON_FILE}
  exit 0
fi

# create /etc/docker/daemon.json file with INSECURE_DOCKER_REPO_URL Repository if file not found
if [[ ! -f ${DOCKER_DAEMON_FILE} ]]
then
  echo "Creating ${DOCKER_DAEMON_FILE} file with ${INSECURE_DOCKER_REPO_URL} Repository configuration as insecure repo"
  echo "
  {
    \"registry-mirrors\": [],
    \"insecure-registries\": [
      \"${INSECURE_DOCKER_REPO_URL}\"
    ],
    \"debug\": false,
    \"experimental\": false
  }
  " | sudo tee ${DOCKER_DAEMON_FILE}
else
  # if /etc/docker/daemon.json already exist, Insert INSECURE_DOCKER_REPO_URL Repository config on insecure-registries definition
  sudo sed -i "/insecure-registries/a \"${INSECURE_DOCKER_REPO_URL}\", " ${DOCKER_DAEMON_FILE}
fi

cat ${DOCKER_DAEMON_FILE}

# Restart docker service for new configuration to be applied
sudo systemctl restart docker

#sudo systemctl status docker

echo "\n ${INSECURE_DOCKER_REPO_URL} configured Successfully as insecure registry at ${DOCKER_DAEMON_FILE} file"
