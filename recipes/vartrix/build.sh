#! /bin/bash

export MACOSX_DEPLOYMENT_TARGET=10.13.4
export CXXFLAGS="${CXXFLAGS} -isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOY  MENT_TARGET}"

cargo build --release

# try to find where binary is. it seems that the binary
# uses some other variable here: target/<other-var>/vartrix
VARTRIX_BIN=$(find . -type f -name "vartrix")
echo $VARTRIX_BIN
cp -a $VARTRIX_BIN ${PREFIX}/bin/vartrix
