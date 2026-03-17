#!/bin/bash

set -xe

mkdir -p "$PREFIX/bin"
cp kent/src/utils/expMatrixToBarchartBed/expMatrixToBarchartBed "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/expMatrixToBarchartBed"
