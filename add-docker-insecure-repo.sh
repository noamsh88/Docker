#!/bin/bash
set -e
####################################################################################################################################
# Script add docker images repository as insecure repo on /etc/docker/daemon.json file and restart docker for changes to be applied
####################################################################################################################################
export DOCKER_IMAGES_REPO_HOST=$1
export DOCKER_IMAGES_REPO_PORT=$2
export DOCKER_DAEMON_FILE_PATH=/etc/docker/daemon.json
####################################################################################################################################

# Validate input values for DOCKER_IMAGES_REPO_HOST and DOCKER_IMAGES_REPO_PORT from script arguments
if [[ -z ${DOCKER_IMAGES_REPO_HOST} || -z ${DOCKER_IMAGES_REPO_PORT} ]]
then
  echo -e ${RED} "USAGE : `basename $0` <Docker images repository server> <Docker images repository port>"
  echo -e "\nExample: bash `basename $0` 172.0.0.1 8080 \n "
  exit 1
fi

# validate if DOCKER_DAEMON_FILE_PATH file exist
if [ -f ${DOCKER_DAEMON_FILE_PATH} ]
then
  # validate if repo name exist already in DOCKER_DAEMON_FILE_PATH
  export REPO_EXISTS=`sudo cat ${DOCKER_DAEMON_FILE_PATH} | grep -i "${DOCKER_IMAGES_REPO_HOST}"`
  if [[ ! -z ${REPO_EXISTS} ]]
  then
    echo "${DOCKER_IMAGES_REPO_HOST} repository configured already in ${DOCKER_DAEMON_FILE_PATH} as insecure-registry, no further action required"
    sudo cat ${DOCKER_DAEMON_FILE_PATH} | grep -i "${DOCKER_IMAGES_REPO_HOST}"
    exit 0
  fi

  # Insert docker images repository to insecure-registires definition
  sudo sed -i "/insecure-registries/a \"${DOCKER_IMAGES_REPO_HOST}:${DOCKER_IMAGES_REPO_PORT}\", "  ${DOCKER_DAEMON_FILE_PATH}
else # if DOCKER_DAEMON_FILE_PATH file not created yet, then:
  # Create DOCKER_DAEMON_FILE_PATH file with new docker images repository host and port definition for insecure repo
  echo "
  {
    \"registry-mirrors\": [],
    \"insecure-registries\": [
      \"${DOCKER_IMAGES_REPO_HOST}:${DOCKER_IMAGES_REPO_PORT}\"
    ],
    \"debug\": false,
    \"experimental\": false
  }
  " | sudo tee ${DOCKER_DAEMON_FILE_PATH}
fi

# Display DOCKER_DAEMON_FILE_PATH file content
cat ${DOCKER_DAEMON_FILE_PATH}

# Restart docker for new configuration to be applied
sudo systemctl restart docker
sudo systemctl status docker
