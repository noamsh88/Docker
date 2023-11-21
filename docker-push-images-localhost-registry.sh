#!/bin/bash
set -exv
###############################################################################
# Script will tag and push all docker images loaded to server per config file #
###############################################################################
# Conf file content format:
# <docker image>:<tag>
# e.g.
# quay.io/prometheus/node-exporter:v1.5.0
# quay.io/prometheus/alertmanager:v0.25.0
###############################################################################
export DOCKER_IMAGES_CONF_FILE=$1

### Script Configurations
export DATE=`date +%Y%m%d_%H%M%S`
export LOG_FILE=~/docker-push-images-localhost-registry-`hostname`-${DATE}.log
export LOCALHOST_DOCKER_REGISTRY=localhost:5000

### Validations
# Validate required docker images list file path is set
if [[ -z ${DOCKER_IMAGES_CONF_FILE} ]]
then
  echo "USAGE: `basename $0` <Docker images config file>"  >> ${LOG_FILE}
  echo -e "\nExample: bash `basename $0` ~/localhost-registry-docker-images-list.conf \n "
  exit 1
fi

# Validate required docker images list file exist on server
if [[ ! -f ${DOCKER_IMAGES_CONF_FILE} ]]
then
  echo "${DOCKER_IMAGES_CONF_FILE} file NOT FOUND at `hostname`, please copy it first and re-run or enter diffrent valid path, exiting.."  >> ${LOG_FILE}
  exit 1
fi

echo "Tag and Push all docker images defined in ${DOCKER_IMAGES_CONF_FILE}..." >> ${LOG_FILE}
for DOCKER_IMAGE_NAME_TAG in `cat ${DOCKER_IMAGES_CONF_FILE}`
do
  # If line in conf file is null, skip docker tag and push operations
  if [[ -z ${DOCKER_IMAGE_NAME_TAG} ]];then
    continue
  fi

  # Tag the Docker image with the localhost docker registry
  echo  "docker tag ${DOCKER_IMAGE_NAME_TAG} ${LOCALHOST_DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME_TAG} \n"  >> ${LOG_FILE}
  docker tag ${DOCKER_IMAGE_NAME_TAG} ${LOCALHOST_DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME_TAG} >> ${LOG_FILE}

  # Push the Docker image to the localhost docker registry
  echo  "docker push ${LOCALHOST_DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME_TAG} \n"  >> ${LOG_FILE}
  docker push ${LOCALHOST_DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME_TAG} >> ${LOG_FILE}
done

echo "All docker images defined at ${DOCKER_IMAGES_CONF_FILE} pushed succesfully to localhost docker registry (${LOCALHOST_DOCKER_REGISTRY})" >> ${LOG_FILE}
docker images | grep "${LOCALHOST_DOCKER_REGISTRY}"
echo "Log Path: ${LOG_FILE}" >> ${LOG_FILE}
