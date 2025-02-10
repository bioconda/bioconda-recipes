#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crisprme"
chmod -R 700 .
unzip PostProcess/pickle_data.zip
mv CRISTA_predictors.pkl PostProcess/
cp crisprme.py "${PREFIX}/bin/" && chmod +rx "${PREFIX}/bin/crisprme.py"
cp src/complete_test.py "${PREFIX}/bin/" && chmod +rx "${PREFIX}/bin/complete_test.py"
cp -R * "${PREFIX}/opt/crisprme/"
