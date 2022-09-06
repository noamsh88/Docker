#!/bin/bash
set -e
######################################################################################
# Script loading docker images to host from given docker saved images directory path #
######################################################################################
export DOCKER_SAVED_IMAGES_DIR=$1
######################################################################################
export DATE=`date +%Y%m%d_%H%M%S`
export LOG_FILE=`pwd`/docker-load-images-`hostname`-${DATE}.log
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export NC='\033[0m' # No Color
######################################################################################

# Validate argument for DOCKER_SAVED_IMAGES_DIR entered
if [[ -z ${DOCKER_SAVED_IMAGES_DIR} ]]
then
  echo | tee -a ${LOG_FILE}
  echo -e ${RED} "USAGE : `basename $0` <Docker saved/exported images directory path> " | tee -a ${LOG_FILE}
  echo -e "\nExample: bash `basename $0` /home/pmc/work/tmp/docker-images-IR-APM6-DEV-M1-20220825_075455  \n " | tee -a ${LOG_FILE}
  echo -e ${NC} | tee -a ${LOG_FILE}
  exit 1
fi

# Validate if docker saved images directory exist
if [[ ! -d ${DOCKER_SAVED_IMAGES_DIR} ]]
then
  echo -e ${RED} "${DOCKER_SAVED_IMAGES_DIR} directory NOT FOUND on `hostname` , please enter argument with correct docker saved/exported images directory path.." | tee -a ${LOG_FILE}
  echo -e ${NC} | tee -a ${LOG_FILE}
  exit 1
fi

# Validate if there are saved images files(tar.gz) on DOCKER_SAVED_IMAGES_DIR directory
export CNT_SAVED_IMAGES=`ls  ${DOCKER_SAVED_IMAGES_DIR}/*tar.gz | wc -l`
if [[ ${CNT_SAVED_IMAGES} -eq 0 ]]
then
  echo -e ${RED} "Docker Saved Images files (.tar.gz) to be loaded NOT FOUND at  ${DOCKER_SAVED_IMAGES_DIR} directory, exiting.." | tee -a ${LOG_FILE}
  echo -e ${NC} | tee -a ${LOG_FILE}
  exit 1
fi

cd ${DOCKER_SAVED_IMAGES_DIR}

# Append docker saved image .tar.gz files to temp docker load images file
ls -ltra *tar.gz | awk '{print $9}' > docker-load-images-`hostname`.sh

# Add docker load command at begining of each line
sed -i "s|^|docker load -i ./|g" docker-load-images-`hostname`.sh

# Execute docker save images script to output all docker images installed in host
bash -xve docker-load-images-`hostname`.sh | tee -a ${LOG_FILE}

echo
echo -e ${GREEN} "Docker load images from : ${DOCKER_SAVED_IMAGES_DIR} directory succesfully loaded to `hostname` host" | tee -a ${LOG_FILE}
echo -e ${NC}
echo "Following are current installed docker images on `hostname`" | tee -a ${LOG_FILE}
docker image ls | tee -a ${LOG_FILE}
