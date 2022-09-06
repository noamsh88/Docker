#!/bin/bash
set -e
########################################################
# Script exporting all docker images installed on host #
########################################################

export DATE=`date +%Y%m%d_%H%M%S`
export BKP_DIR=`pwd`/docker-images-`hostname`-${DATE}
mkdir -p ${BKP_DIR}
cd ${BKP_DIR}

# Append docker image list and tag to temp file per following naming convention:
# 1. <docker image name>-<tag name>
# 2. replace / with -
# 3. add -image.tar.gz at ending
docker image ls | grep -v REPOSITORY  | awk '{print " -o "$1"-"$2"-image.tar.gz"}' | sed 's/\//-/g' > temp-docker-images-export-file-names.lst

# Append docker image list and tag to temp file per following naming convention:
# <docker image name>:<tag name>
docker image ls | grep -v REPOSITORY  | awk '{print $1":"$2}' > temp-docker-images-tag.lst

# Merge 2 temp files to main docker save images file
paste temp-docker-images-tag.lst  temp-docker-images-export-file-names.lst | column -s $'\t' -t > docker-save-images.sh

# Delete temp files after merge
rm -fr temp-docker-images-export-file-names.lst temp-docker-images-tag.lst

# Add docker save command at begining of each line
sed -i 's/^/docker save /g' docker-save-images.sh

# Execute docker save images script to output all docker images installed in host
bash -ve docker-save-images.sh

echo
echo "Docker Images Succesfully saved under : ${BKP_DIR} directory"
echo
ls -ltra ${BKP_DIR}
