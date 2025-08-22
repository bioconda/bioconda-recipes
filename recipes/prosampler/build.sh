#!/bin/bash

mkdir -p "$PREFIX/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

${CXX} -O3 -o ProSampler ProSampler_v1.5.cc

install -v -m 0755 ProSampler "$PREFIX/bin"
