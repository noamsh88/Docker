#!/bin/bash
set -exv
#################################################################################################
# Script will tag and push given docker image loaded to server to ProGet docker images repository
#################################################################################################
export IMAGE_NAME=$1

### Script Configurations
export DATE=`date +%Y%m%d_%H%M%S`
export IMG_NAME=`echo ${IMAGE_NAME} | sed 's|/|-|g'`
export LOG_FILE=`pwd`/docker-push-image-${IMG_NAME}-proget-`hostname`-${DATE}.log

# Set the ProGet server URL
export PROGET_SERVER_URL='<ProGet Server>:<Port Number>'
# Set the ProGet user name for login via docker CLI
export USER_NAME='<ProGet User Name>'
# Set the ProGet feed name
export FEED_NAME='<Docker Repository name in Proget (feed name)>'

### Validations
if [[ -z ${IMAGE_NAME} ]]
then
  echo "USAGE : `basename $0` <Docker Image Name> "  >> ${LOG_FILE}
  echo "\nExample: bash `basename $0` opensearchproject/opensearch  \n "  >> ${LOG_FILE}
  exit 1
fi

# Validate required ProGet variables values are set
if [[ -z ${PROGET_SERVER_URL} || -z ${USER_NAME} || -z ${FEED_NAME} ]]
then
  echo "Error: 1 or more of following variables values are null:"  >> ${LOG_FILE}
  echo "PROGET_SERVER_URL:    ${PROGET_SERVER_URL}"  >> ${LOG_FILE}
  echo "USER_NAME:    ${USER_NAME}"  >> ${LOG_FILE}
  echo "FEED_NAME:    ${FEED_NAME}"  >> ${LOG_FILE}
  exit 1
fi

# Check if Docker is installed
if ! [ -x "$(command -v docker)" ]
then
  echo "Error: Docker is not installed." >> ${LOG_FILE}
  exit 1
fi

# Check if the secret.txt file exists
if [ ! -f secret.txt ]
then
 echo "Error: secret.txt file not found." >> ${LOG_FILE}
 exit 1
fi

# Validate if image name loaded to server
if [[ -z `docker images | grep "${IMAGE_NAME}"` ]]; then
    echo "Image ${IMAGE_NAME} is not loaded to `hostname`, exiting.." >> ${LOG_FILE}
    docker images
    exit 1
fi

### Log in to the ProGet server
echo "Logging in to ProGet server at ${PROGET_SERVER_URL}..."  >> ${LOG_FILE}
cat secret.txt | docker login ${PROGET_SERVER_URL} --username ${USER_NAME} --password-stdin

# Get given Docker Image Tag
export IMAGE_TAG=`docker images | grep "${IMAGE_NAME}" | tail -1 | awk '{print $2}'`

# Tag the Docker image with the ProGet server URL and feed name
echo -e ${CYAN} "docker tag ${IMAGE_NAME} ${PROGET_SERVER_URL}/${FEED_NAME}/${IMAGE_NAME} \n"  >> ${LOG_FILE}
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${PROGET_SERVER_URL}/${FEED_NAME}/${IMAGE_NAME}:${IMAGE_TAG} >> ${LOG_FILE}

# Push the Docker image to the ProGet server
echo -e ${CYAN} "docker push ${PROGET_SERVER_URL}/${FEED_NAME}/${IMAGE_NAME} \n"  >> ${LOG_FILE}
docker push ${PROGET_SERVER_URL}/${FEED_NAME}/${IMAGE_NAME}:${IMAGE_TAG} >> ${LOG_FILE}

# Log out of the ProGet server
echo "Logging out of ProGet server at ${PROGET_SERVER_URL}..."  >> ${LOG_FILE}
docker logout ${PROGET_SERVER_URL} >> ${LOG_FILE}

echo >> ${LOG_FILE}
echo "Docker image ${IMAGE_NAME} installed on `hostname` pushed succesfully to ${PROGET_SERVER_URL}/${FEED_NAME} repository" >> ${LOG_FILE}
echo "Log Path: ${LOG_FILE}" >> ${LOG_FILE}
