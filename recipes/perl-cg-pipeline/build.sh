#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    TMP_DIR=`mktemp -d -t 'tmpdir'`
else
    TMP_DIR=`mktemp -d`
fi


BUILD_DIR=${TMP_DIR}
mkdir -p ${BUILD_DIR}/lib

cd ${BUILD_DIR}
cp -R ${SRC_DIR}/lib/* ${BUILD_DIR}/lib/
cp ${RECIPE_DIR}/Makefile.PL ${BUILD_DIR}/Makefile.PL

perl Makefile.PL INSTALLDIRS=site
make
make install
