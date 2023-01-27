#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crisprme"
chmod -R 700 .
ls -al ./
unzip ${SRC_DIR}/PostProcess/pickle_data.zip
ls -al ${SRC_DIR}
las -al ${SRC_DIR}/PostProcess/
mv ${SRC_DIR}/PostProcess/CRISTA_predictors.pkl ${SRC_DIR}/PostProcess/
cp crisprme.py "${PREFIX}/bin/"
cp crisprme_test_complete_package.sh "${PREFIX}/bin/"
cp -R * "${PREFIX}/opt/crisprme/"