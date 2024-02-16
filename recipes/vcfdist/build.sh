#!/bin/bash

export C_INCLUDE_PATH="${PREFIX}/include"
export LD_LIBRARY_PATH="${PREFIX}/lib"

cd src && make
install -d "${PREFIX}/bin"
install vcfdist "${PREFIX}/bin"
