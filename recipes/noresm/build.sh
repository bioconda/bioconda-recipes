#!/bin/bash

# Fix problem with python 3.8 and later 
# See https://bb.cgd.ucar.edu/cesm/threads/known-issue-running-manage_externals-with-python-3-8-and-later.5072/

rm -r manage_externals
git clone -b manic-v1.1.8 https://github.com/ESMCI/manage_externals.git

sed -i.bak "s/'checkout'/'checkout', '--trust-server-cert'/" ./manage_externals/manic/repository_svn.py
./manage_externals/checkout_externals

patch cime/config/cesm/machines/config_compilers.xml ${RECIPE_DIR}/config_compilers_xml.patch
patch cime/config/cesm/machines/config_machines.xml ${RECIPE_DIR}/config_machines_xml.patch
patch cime/scripts/lib/CIME/case/case.py ${RECIPE_DIR}/case.py.patch
patch ./components/clm/src/biogeochem/ch4Mod.F90 ${RECIPE_DIR}/ch4Mod.F90.patch
patch ./components/cam/src/NorESM/micro_mg2_0.F90 ${RECIPE_DIR}/micro_mg2_0.F90.patch
patch ./components/cam/src/physics/cam/micro_mg2_0.F90 ${RECIPE_DIR}/micro_mg2_0.F90.patch
patch ./cime/src/drivers/mct/shr/seq_infodata_mod.F90 ${RECIPE_DIR}/seq_infodata_mod.F90.patch

mkdir -p ${PREFIX}/bin
cp -r cime ${PREFIX}/
cp -r cime_config ${PREFIX}/
cp -r components ${PREFIX}/

cd ${PREFIX}/bin/
ln -s ../cime/scripts/create_* .
ln -s ../cime/scripts/query_* .

# Change csh by tcsh 
list_files=$(find ${PREFIX} -name *.csh)
for file in $list_files; do  sed -i.bak 's|#!/usr/bin/csh -f|#!/usr/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#!/usr/bin/csh|#!/usr/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#!/bin/csh -f|#!/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#!/bin/csh|#!/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#! /bin/csh -f|#!/bin/env tcsh|' $file; done
for file in $list_files; do  sed -i.bak 's|#!/bin/tcsh|#!/bin/env tcsh|' $file; done

