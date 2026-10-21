#!/bin/bash

set -xe

mkdir -p "$PREFIX/bin"
cp kent/src/utils/expMatrixToBarchartBed/expMatrixToBarchartBed "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/expMatrixToBarchartBed"
# upstream shebangs drift between python2.7, python and python3
sed -i '1s|^#!.*python.*|#!/usr/bin/env python3|' "${PREFIX}/bin/expMatrixToBarchartBed"
