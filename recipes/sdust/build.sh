#!/bin/bash

set -x -e

export CPATH=${PREFIX}/include

mkdir -p "${PREFIX}/bin"

make CC="$CC"

chmod +x sdust

cp sdust "${PREFIX}/bin"

