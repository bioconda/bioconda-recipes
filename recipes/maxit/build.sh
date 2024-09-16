#!/bin/bash

set -exo pipefail

# Disable parallel build
export CPU_COUNT=1

ln -s "${CC_FOR_BUILD}" "${BUILD_PREFIX}/bin/gcc"
ln -s "${CXX_FOR_BUILD}" "${BUILD_PREFIX}/bin/g++"

cd "${SRC_DIR}/cifparse-obj-v7.0"
sed -i.bak 's|mv |cp |g' Makefile
rm *.bak

cd "${SRC_DIR}"
make binary "-j${CPU_COUNT}"

unlink "${BUILD_PREFIX}/bin/gcc"
unlink "${BUILD_PREFIX}/bin/g++"

install -d "${PREFIX}/bin"
install ${SRC_DIR}/bin/* "${PREFIX}/bin"
cp -r "${SRC_DIR}/data" "${PREFIX}/data"
