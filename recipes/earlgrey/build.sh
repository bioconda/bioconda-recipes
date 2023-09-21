#!/bin/bash

SCRIPT_DIR=$(realpath scripts)

mkdir -p "${PREFIX}/bin"

sed -i.bak "s|usage; exit 1|usage; exit 0|g" earlGrey
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" earlGrey
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" scripts/rcMergeRepeat*
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" scripts/headSwap.sh
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" scripts/autoPie.sh
sed -i.bak "s|INSERT_FILENAME_HERE|${SCRIPT_DIR}/TEstrainer/scripts/|g" scripts/TEstrainer/TEstrainer_for_earlGrey.sh

chmod +x earlGrey
chmod +x ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh
chmod +x ${SCRIPT_DIR}/* > /dev/null 2>&1
chmod +x ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/ltr_finder
chmod a+w ${SCRIPT_DIR}/repeatCraft/example
chmod +x modules/trf409.linux64

tar -zxf ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/tRNAdb.tar.gz --directory ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7

cp earlGrey ${PREFIX}/bin/earlGrey
