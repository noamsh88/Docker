#!/bin/bash
set -exv
################################################################################################
# Script will tag and push all docker images loaded to server to ProGet docker images repository
################################################################################################

### Script Configurations
export DATE=`date +%Y%m%d_%H%M%S`
export LOG_FILE=`pwd`/docker-push-all-server-images-proget-`hostname`-${DATE}.log

# Set the ProGet server URL
export PROGET_SERVER_URL='<ProGet Server>:<Port Number>'
# Set the ProGet user name for login via docker CLI
export USER_NAME='<ProGet User Name>'
# Set the ProGet feed name
export FEED_NAME='<Docker Repository name in Proget (feed name)>'

### Validations
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
if ! [ -x "$(command -v docker)" ]; then
  echo "Error: Docker is not installed." >> ${LOG_FILE}
  exit 1
fi

# Check if the secret.txt file exists
if [ ! -f secret.txt ]; then
 echo "Error: secret.txt file not found." >> ${LOG_FILE}
 exit 1
fi

### Log in to the ProGet server
echo "Logging in to ProGet server at ${PROGET_SERVER_URL}..."  >> ${LOG_FILE}
cat secret.txt | docker login ${PROGET_SERVER_URL} --username ${USER_NAME} --password-stdin

echo "Tag and Push all docker images that exist on server to ProGet Server..." >> ${LOG_FILE}
for DOCKER_IMAGE_NAME_TAG in `docker images | grep -v REPOSITORY | grep -v "${PROGET_SERVER_URL}" | awk '{print $1":"$2}'`
do
  # Tag the Docker image with the ProGet server URL and feed name
  echo -e ${CYAN} "docker tag ${DOCKER_IMAGE_NAME_TAG} ${PROGET_SERVER_URL}/${FEED_NAME}/${DOCKER_IMAGE_NAME_TAG} \n"  >> ${LOG_FILE}
  docker tag ${DOCKER_IMAGE_NAME_TAG} ${PROGET_SERVER_URL}/${FEED_NAME}/${DOCKER_IMAGE_NAME_TAG} >> ${LOG_FILE}
  # Push the Docker image to the ProGet server
  echo -e ${CYAN} "docker push ${PROGET_SERVER_URL}/${FEED_NAME}/${DOCKER_IMAGE_NAME_TAG} \n"  >> ${LOG_FILE}
  docker push ${PROGET_SERVER_URL}/${FEED_NAME}/${DOCKER_IMAGE_NAME_TAG} >> ${LOG_FILE}
done

# Log out of the ProGet server
echo "Logging out of ProGet server at ${PROGET_SERVER_URL}..."  >> ${LOG_FILE}
docker logout ${PROGET_SERVER_URL} >> ${LOG_FILE}

echo >> ${LOG_FILE}
echo "All docker images installed on `hostname` pushed succesfully to ${PROGET_SERVER_URL}/${FEED_NAME} repository" >> ${LOG_FILE}
echo "Log Path: ${LOG_FILE}" >> ${LOG_FILE}
