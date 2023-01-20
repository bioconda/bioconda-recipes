#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crisprme"
chmod -R 700 .
ls -al ${PREFIX}
ls -al ${BUILD_PREFIX}
ls -al ${SRC_DIR}
unzip PostProcess/pickle_data.zip
mv CRISTA_predictors.pkl PostProcess/
cp crisprme.py "${PREFIX}/bin/"
cp crisprme_test_complete_package.sh "${PREFIX}/bin/"
cp -R * "${PREFIX}/opt/crisprme/"