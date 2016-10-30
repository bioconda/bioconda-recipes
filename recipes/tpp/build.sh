#!/bin/bash

set -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export C_INCLUDE_PATH=${INCLUDE_PATH}
export CPLUS_INCLUDE_PATH=${INCLUDE_PATH}
export TARGET=x86_64-unknown-linux-gnu
cp ${RECIPE_DIR}/site.mk .
cp ${RECIPE_DIR}/common.mk .
ls -l

cp ${RECIPE_DIR}/Makefile_ProteoWizard extern/ProteoWizard/

#cd extern/ProteoWizard/
#mkdir pwiz-msi
#make pwiz-msi

#cd ../..

make info
make all
make install
