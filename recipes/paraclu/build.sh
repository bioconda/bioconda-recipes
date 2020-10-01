#!/bin/bash

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}"

mkdir -p "${PREFIX}/bin"
cp paraclu "${PREFIX}/bin/"
sed -i -e '1s,^#! */bin/sh,#!/bin/bash,' paraclu-cut.sh
cp paraclu-cut.sh "${PREFIX}/bin/paraclu-cut"
