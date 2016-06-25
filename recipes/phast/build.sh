#!/bin/bash

CLAPACK_VERSION=3.2.1

# download extra sources using conda's mechanism
# see: https://github.com/stuarteberg/conda-multisrc-example
CONDA_PYTHON=$(conda info --root)/bin/python
${CONDA_PYTHON} ${RECIPE_DIR}/download-extra-sources.py

WORK_DIR=`dirname $SRC_DIR`
SRC_CLAPACK=$WORK_DIR/clapack/CLAPACK-${CLAPACK_VERSION}

####
# build clapack
####

cd $SRC_CLAPACK
cp make.inc.example make.inc && make f2clib && make blaslib && make lib


####
# build phast
####

cd $SRC_DIR/src
make CLAPACKPATH=$SRC_CLAPACK all
mkdir -p $PREFIX/bin
cp -r $SRC_DIR/bin/* $PREFIX
