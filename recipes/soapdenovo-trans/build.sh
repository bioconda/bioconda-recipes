#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib

mkdir -p ${PREFIX}/bin
sh make.sh
cp ${SRC_DIR}/{SOAPdenovo-Trans-127mer,SOAPdenovo-Trans-31mer} ${PREFIX}/bin
