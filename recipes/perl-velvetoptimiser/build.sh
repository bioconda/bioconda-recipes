#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    TMP_DIR=`mktemp -d -t 'tmpdir'`
else
    TMP_DIR=`mktemp -d`
fi

BUILD_DIR=${TMP_DIR}/VelvetOpt
mkdir -p ${PREFIX}/bin
cp VelvetOptimiser.pl ${PREFIX}/bin
cd ${TMP_DIR}
h2xs -AX -n VelvetOpt
rm ${BUILD_DIR}/lib/VelvetOpt.pm
cp -R ${SRC_DIR}/VelvetOpt ${BUILD_DIR}/lib
cp ${RECIPE_DIR}/{MANIFEST,Makefile.PL} ${BUILD_DIR}
cd ${BUILD_DIR}
perl Makefile.PL INSTALLDIRS=site
make
make install
