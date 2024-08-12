#!/bin/bash

set -x -e

mkdir -p "${PREFIX}/bin"

make CC="$CC" INCLUDES="${PREFIX}/include" -j ${CPU_COUNT}

chmod 0755 sdust

cp -rf sdust "${PREFIX}/bin"
