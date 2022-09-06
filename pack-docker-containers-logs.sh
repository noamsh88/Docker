#!/bin/bash
set -e
####################################################################################################################################
#Script extract and pack docker logs of all containers deployed on host
####################################################################################################################################
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
####################################################################################################################################
export DATE=`date +%Y%m%d_%H%M%S`
export OPT_LOG_DIR=$(pwd)/$(hostname)_containers_logs_${DATE}
export LOGS_DIR_NAME=$(basename ${OPT_LOG_DIR})
####################################################################################################################################

# Validate script to be excuted as root
if [[ ${USER} -ne "root" ]]
then
  echo -e ${RED} "Script to be executed as root user"
  echo -e ${NC}
  exit 1
fi

# Validate if docker installed
which docker
if [[ $? -ne 0 ]]
then
  echo -e ${RED} "Docker NOT FOUND on $(hostname) , please verify it setup correctly"
  echo -e ${NC}
  exit 1
fi

# Get docker container list, exit if no docker containers deployed
HAS_CONTAINERS=$(docker container ls | awk '{print $1}' | grep -v CONTAINER)
if [[ -z ${HAS_CONTAINERS} ]]
then
  echo -e ${YELLOW} "No docker containers found at $(hostname) host"
  echo -e ${NC}
  exit 0
fi

# Extract docker logs of all containers
for CONTAINER_ID in $(docker container ls | awk '{print $1}' | grep -v CONTAINER)
do
  docker logs ${CONTAINER_ID} >& ${CONTAINER_ID}_$(hostname)_container_logs_${DATE}.log
done

# Pack Log Files
mkdir -p ${OPT_LOG_DIR}
mv *_$(hostname)_container_logs_${DATE}.log ${OPT_LOG_DIR}
tar -cvf ${LOGS_DIR_NAME}.tar ${LOGS_DIR_NAME}
gzip ${LOGS_DIR_NAME}.tar

echo -e ${GREEN} "$(hostname) docker containers logs extracted and packed to following tar.gz file: "
echo "${OPT_LOG_DIR}.tar.gz"
echo -e ${NC}
