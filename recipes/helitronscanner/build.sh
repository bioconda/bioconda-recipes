#!/bin/sh
set -x -e

HELITRONSCANNER_DIR=${PREFIX}/share/HelitronScanner
HELITRONSCANNER_TRAININGSET_PATH=${HELITRONSCANNER_DIR}/TrainingSet

mkdir -p ${PREFIX}/bin
mkdir -p ${HELITRONSCANNER_DIR}
mkdir -p ${HELITRONSCANNER_TRAININGSET_PATH}

cp -r HelitronScanner/* ${HELITRONSCANNER_DIR}
cp -r TrainingSet/* ${HELITRONSCANNER_TRAININGSET_PATH}

ln -s ${HELITRONSCANNER_DIR}/HelitronScanner.jar ${PREFIX}/bin/HelitronScanner.jar
chmod +x ${PREFIX}/bin/HelitronScanner.jar

ln -s ${HELITRONSCANNER_DIR}/scala-actors.jar ${PREFIX}/bin/scala-actors.jar
ln -s ${HELITRONSCANNER_DIR}/scala-library.jar ${PREFIX}/bin/scala-library.jar
ln -s ${HELITRONSCANNER_DIR}/xww.basic.jar ${PREFIX}/bin/xww.basic.jar

## Set HelitronScanner variables on env activation

mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/helitronscanner.sh
export HELITRONSCANNER_TRAININGSET_PATH=${HELITRONSCANNER_TRAININGSET_PATH}
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/helitronscanner.sh
unset HELITRONSCANNER_TRAININGSET_PATH
EOF
