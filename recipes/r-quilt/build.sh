#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

export LC_ALL="en_US.UTF-8"
export DISABLE_AUTOBREW=1

install -v -m 0755 ${SRC_DIR}/*.R "${PREFIX}/bin"

cd ${SRC_DIR}/QUILT
${R} CMD INSTALL --build --install-tests . "${R_ARGS}"
