#!/bin/bash

sed -i.bak "s/'checkout'/'checkout', '--trust-server-cert'/" ./manage_externals/manic/repository_svn.py
./manage_externals/checkout_externals

mkdir -p ${PREFIX}/bin
cp -r cime ${PREFIX}/
cp -r cime_config ${PREFIX}/
cp -r components ${PREFIX}/

cd ${PREFIX}/bin/
ln -s ../cime/scripts/create_* .
ln -s ../cime/scripts/query_* .

sed -i.bak 's/# ARCHIVE COMMAND SIMILAR ACROSS ALL PLATFORMS/AR="$AR cq"/' ${PREFIX}/cime/src/externals/mct/configure  
