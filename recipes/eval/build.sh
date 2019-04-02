#!/bin/bash


# Copy scripts
chmod +x *.pl
chmod +x *.py
cp *.pl ${PREFIX}/bin
cp *.py ${PREFIX}/bin


# Run Makefile.PL
if [ "$(uname)" == "Darwin" ]; then
    TMP_DIR=`mktemp -d -t 'tmpdir'`
else
    TMP_DIR=`mktemp -d`
fi

BUILD_DIR=${TMP_DIR}
mkdir -p ${BUILD_DIR}/lib/

cd ${BUILD_DIR}
cp  ${SRC_DIR}/*.pm ${BUILD_DIR}/lib/
cp ${RECIPE_DIR}/Makefile.PL ${BUILD_DIR}

perl Makefile.PL INSTALLDIRS=site
make
make install
