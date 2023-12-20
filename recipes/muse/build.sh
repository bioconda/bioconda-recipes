#!/usr/bin/env bash

make CPP="${CXX}" CPPFLAGS="${CXXFLAGS}"

mkdir -p "${PREFIX}/bin"
cp MuSE "${PREFIX}/bin/"
