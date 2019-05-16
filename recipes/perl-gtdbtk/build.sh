#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    TMP_DIR=`mktemp -d -t 'tmpdir'`
else
    TMP_DIR=`mktemp -d`
fi


BUILD_DIR=${TMP_DIR}/Bio-Pfam
mkdir -p ${BUILD_DIR}/lib/

cd ${BUILD_DIR}
cp -R ${SRC_DIR}/gtdbtk/external/Bio ${BUILD_DIR}/lib
cp ${SRC_DIR}/gtdbtk/external/pfam_search.pl ${BUILD_DIR}
cp ${RECIPE_DIR}/Makefile.PL ${BUILD_DIR}

perl Makefile.PL INSTALLDIRS=site
make
make install
