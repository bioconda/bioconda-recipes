#!/bin/bash
mkdir -p "$PREFIX/bin"
if [ "$(uname)" == "Darwin" ]; then
    cp expMatrixToBarchartBed "$PREFIX/bin"
else
    cp kent/src/utils/expMatrixToBarchartBed/expMatrixToBarchartBed "$PREFIX/bin"
fi
chmod +x "$PREFIX/bin/expMatrixToBarchartBed"
