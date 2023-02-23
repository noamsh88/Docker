#!/bin/bash
set -exv
##################################################################
# Script get image name and its tag and pull it from ProGet server
##################################################################
export IMAGE_NAME=$1
export IMAGE_TAG=$2

### Script Configurations
export DATE=`date +%Y%m%d_%H%M%S`
export IMG_NAME=`echo ${IMAGE_NAME} | sed 's|/|-|g'`
export LOG_FILE=`pwd`/docker-pull-image-${IMG_NAME}-proget-`hostname`-${DATE}.log

### Set ProGet Server Variables (PROGET_SERVER_URL,USER_NAME and FEED_NAME)
# Set the ProGet server URL
export PROGET_SERVER_URL='<Repo Server Name/IP address>:<Port>'
# Set the ProGet user name for login via docker CLI
export USER_NAME=
# Set the ProGet feed name
export FEED_NAME=

### Validations
if [[ -z ${IMAGE_NAME} || -z ${IMAGE_TAG} ]]
then
  echo "USAGE : `basename $0` <Docker Image Name> <Image Tag> <> "  >> ${LOG_FILE}
  echo "\nExample: bash `basename $0` opensearchproject/opensearch 2.3.0  \n "  >> ${LOG_FILE}
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

### Log in to the ProGet server
echo "Logging in to ProGet server at ${PROGET_SERVER_URL}..."  >> ${LOG_FILE}
cat secret.txt | docker login ${PROGET_SERVER_URL} --username ${USER_NAME} --password-stdin

# Pull the Docker image per its tag name from ProGet server
docker pull ${PROGET_SERVER_URL}/${FEED_NAME}/${IMAGE_NAME}:${IMAGE_TAG} >> ${LOG_FILE}

# Log out of the ProGet server
echo "Logging out of ProGet server at ${PROGET_SERVER_URL}..."  >> ${LOG_FILE}
docker logout ${PROGET_SERVER_URL} >> ${LOG_FILE}

echo "\n Docker image ${IMAGE_NAME}:${IMAGE_TAG} pulled succesfully" >> ${LOG_FILE}
docker images | grep ${IMAGE_NAME} >> ${LOG_FILE}
echo "Log Path: ${LOG_FILE}" >> ${LOG_FILE}
