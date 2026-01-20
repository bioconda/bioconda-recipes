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
sed -i.bak 's/# ARCHIVE COMMAND SIMILAR ACROSS ALL PLATFORMS/AR="$AR cq"/' ${PREFIX}/cime/src/externals/mct/mpi-serial/configure

# add espress machines & associated compilers
patch  ${PREFIX}/cime/config/cesm/machines/config_machines.xml ${RECIPE_DIR}/config_machines_xml.patch
patch  ${PREFIX}/cime/config/cesm/machines/config_compilers.xml ${RECIPE_DIR}/config_compilers_xml.patch

# Change csh by tcsh 
list_files=$(find ${PREFIX} -name *.csh)
for file in $list_files; do  sed -i.bak 's|#!/usr/bin/csh -f|#!/usr/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#!/usr/bin/csh|#!/usr/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#!/bin/csh -f|#!/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#!/bin/csh|#!/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#! /bin/csh -f|#!/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#!/bin/tcsh|#!/bin/env tcsh|' $file; done
