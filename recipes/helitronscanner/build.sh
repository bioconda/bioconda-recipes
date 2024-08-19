#!/bin/sh
set -x -e

HELITRONSCANNER_DIR=${PREFIX}/share/HelitronScanner
HELITRONSCANNER_TRAININGSET_PATH=${HELITRONSCANNER_DIR}/TrainingSet

mkdir -p ${PREFIX}/bin
mkdir -p ${HELITRONSCANNER_DIR}
mkdir -p ${HELITRONSCANNER_TRAININGSET_PATH}

cp -r HelitronScanner/* ${HELITRONSCANNER_DIR}
cp -r TrainingSet/* ${HELITRONSCANNER_TRAININGSET_PATH}

cp ${RECIPE_DIR}/HelitronScanner.sh ${HELITRONSCANNER_DIR}/HelitronScanner
chmod +x ${HELITRONSCANNER_DIR}/HelitronScanner
ln -s ${HELITRONSCANNER_DIR}/HelitronScanner ${PREFIX}/bin

## Set HelitronScanner variables on env activation for training set access
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/helitronscanner.sh
export HELITRONSCANNER_PATH=${HELITRONSCANNER_DIR}
export HELITRONSCANNER_TRAININGSET_PATH=${HELITRONSCANNER_TRAININGSET_PATH}
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/helitronscanner.sh
unset HELITRONSCANNER_PATH
unset HELITRONSCANNER_TRAININGSET_PATH
EOF
