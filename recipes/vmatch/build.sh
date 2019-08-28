#!/bin/bash
# Copied and adapted from https://github.com/RSAT-doc/rsat-conda/blob/master/vmatch/build.sh

set -euxo pipefail

# Those variables are also used in pre and post-link scripts
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
DOC_DIR="$SHARE_DIR"/doc

# Create directories
mkdir -p ${BIN_DIR}
mkdir -p ${SHARE_DIR}
mkdir -p ${DOC_DIR}
mkdir -p ${PREFIX}/lib

# Copy binaries and scripts
# perl scripts use /usr/bin/env so there is no need to do modify them
if [[ "$OSTYPE" == "darwin"* ]]; then
    find . -maxdepth 1 -type f -perm +111 -exec cp -p \{\} ${BIN_DIR} \;
else
    find . -maxdepth 1 -type f -executable -exec cp -p \{\} ${BIN_DIR} \;
fi

# Compile selection functions and install them.
# The SYSTEM variable is not really needed
# but we set it as should be done.
# The libs are installed in ${PREFIX}/lib so `vmatch`
# can find them without the full path
# (thanks to rpath modification by conda).
pushd SELECT
SYSTEM=$(uname -s) make
cp -p *.so ${PREFIX}/lib
popd

# Copy data, doc and various files
cp -r TRANS ${SHARE_DIR}
cp *.pdf ${DOC_DIR}
cp LICENSE README.distrib CHANGELOG ${SHARE_DIR}
