#!/bin/bash
set -exv
#####################################################################################################################################
# Script get image name and its tag and pull and save it into tar.gz file (for using docker load purposes in isolated network envs) #
#####################################################################################################################################
export IMAGE_NAME=$1
export IMAGE_TAG=$2

# Script Configurations
export OPT_DOCKER_IMAGE_FILE_TMP=${IMAGE_NAME}/${IMAGE_TAG}.tar.gz
export OPT_DOCKER_IMAGE_FILE=`echo ${OPT_DOCKER_IMAGE_FILE_TMP} | sed 's|/|-|g'`

# Validate script arguments entered
if [[ -z ${IMAGE_NAME} || -z ${IMAGE_TAG} ]]
then
  echo "USAGE : `basename $0` <Docker Image Name> <Image Tag> <> "
  echo "\nExample: bash `basename $0` opensearchproject/opensearch 2.3.0  \n "
  exit 1
fi

# Pull the Docker image
docker pull ${IMAGE_NAME}:${IMAGE_TAG}

# Save the Docker image
echo "Logging out of ProGet server at ${PROGET_SERVER_URL}..."
docker save ${IMAGE_NAME}:${IMAGE_TAG} -o /tmp/${OPT_DOCKER_IMAGE_FILE}

# Remove docker image from server
docker rmi -f ${IMAGE_NAME}:${IMAGE_TAG}

echo "\n Docker image ${IMAGE_NAME}:${IMAGE_TAG} pulled and saved succesfully"
echo "Packed Docker Image File: /tmp/${OPT_DOCKER_IMAGE_FILE}"
