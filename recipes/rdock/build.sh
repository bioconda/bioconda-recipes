#!/bin/bash

set -euo pipefail

LDFLAGS="${LDFLAGS} -L${BUILD_PREFIX}/lib -lpopt"
make -j${CPU_COUNT} LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d
cp ${RECIPE_DIR}/activate.sh ${PREFIX}/etc/conda/activate.d/activate.sh
cp ${RECIPE_DIR}/deactivate.sh ${PREFIX}/etc/conda/deactivate.d/deactivate.sh
