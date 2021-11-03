#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crisprme"
chmod -R 700 .
unzip PostProcess/CRISTA_predictors.zip
mv CRISTA_predictors.pkl PostProcess/
cp crisprme.py "${PREFIX}/bin/"
cp crisprme_test_complete_package.sh "${PREFIX}/bin/"
cp -R * "${PREFIX}/opt/crisprme/"
