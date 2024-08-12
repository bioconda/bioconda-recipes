#!/bin/bash

set -x -e

export CPATH=${PREFIX}/include

mkdir -p "${PREFIX}/bin"

make CC="$CC" -j ${CPU_COUNT}

chmod 0755 sdust

cp -rf sdust "${PREFIX}/bin"
