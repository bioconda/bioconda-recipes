#!/bin/bash
# Copied and adapted from https://github.com/RSAT-doc/rsat-conda/blob/master/vmatch/build.sh

set -euxo pipefail

# Those variables are also used in pre and post-link scripts
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
PLUGIN_DIR="$SHARE_DIR"/plugin
DOC_DIR="$SHARE_DIR"/doc

# Create directories
mkdir -p ${BIN_DIR}
mkdir -p ${PLUGIN_DIR}
mkdir -p ${SHARE_DIR}
mkdir -p ${DOC_DIR}

# Copy binaries and scripts
# perl scripts use /usr/bin/env so there is no need to do modify them
find . -maxdepth 1 -type f -executable -exec cp -p \{\} ${BIN_DIR} \;

# Compile selection functions
# SYSTEM is not really needed
pushd SELECT
SYSTEM=$(uname -s) make
cp -p *.so ${PLUGIN_DIR}
popd

# Copy data, doc and various files
cp -r TRANS ${SHARE_DIR}
cp *.pdf ${DOC_DIR}
cp LICENSE README.distrib CHANGELOG ${SHARE_DIR}
