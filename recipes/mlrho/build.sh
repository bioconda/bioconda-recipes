#!/bin/bash
export CFLAGS="${CFLAGS} -fcommon"
make
mkdir -p "${PREFIX}/bin"
cp mlRho "${PREFIX}/bin/"
