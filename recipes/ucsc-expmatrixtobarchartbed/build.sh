#!/bin/bash
mkdir -p "$PREFIX/bin"
cp kent/src/utils/expMatrixToBarchartBed/expMatrixToBarchartBed "$PREFIX/bin"
chmod +x "$PREFIX/bin/expMatrixToBarchartBed"
