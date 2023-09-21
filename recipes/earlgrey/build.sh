#!/bin/bash
#This is the build.sh script for the bioconda recipe for EarlGrey
#
#From the dockerfile:
#SCRIPT_DIR=$(realpath ./scripts/)
#sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ./earlGrey
#sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ./scripts/rcMergeRepeat*
#sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ./scripts/headSwap.sh
#sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ./scripts/autoPie.sh
#sed -i "s|INSERT_FILENAME_HERE|${SCRIPT_DIR}/TEstrainer/scripts/|g" ./scripts/TEstrainer/TEstrainer_for_earlGrey.sh
#chmod +x ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh
#chmod +x ${SCRIPT_DIR}/* > /dev/null 2>&1
#chmod +x ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/ltr_finder
#chmod a+w ${SCRIPT_DIR}/repeatCraft/example/
#chmod +x ./modules/trf409.linux64
#
#Now, we write a bash instruction on top of the prerequisities already installed because of the meta.yaml

SCRIPT_DIR=$(realpath ./scripts/)
sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ./earlGrey
sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ./scripts/rcMergeRepeat*
sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ./scripts/headSwap.sh
sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ./scripts/autoPie.sh
sed -i "s|INSERT_FILENAME_HERE|${SCRIPT_DIR}/TEstrainer/scripts/|g" ./scripts/TEstrainer/TEstrainer_for_earlGrey.sh
chmod +x ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh
chmod +x ${SCRIPT_DIR}/* > /dev/null 2>&1
chmod +x ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/ltr_finder
chmod a+w ${SCRIPT_DIR}/repeatCraft/example/
chmod +x ./modules/trf409.linux64

tar -zxf ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/tRNAdb.tar.gz --directory ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/

cp earlGrey ${PREFIX}/bin/earlGrey
