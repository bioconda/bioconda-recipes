#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crisprme"
chmod -R 700 .
cp crisprme.py "${PREFIX}/bin/"
cp crisprme_test_complete_package.sh "${PREFIX}/bin/"
cp -R * "${PREFIX}/opt/crisprme/"
