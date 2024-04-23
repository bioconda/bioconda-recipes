#!/bin/bash
set -eu -o pipefail
mkdir -p ${PREFIX}/bin
make CC=${CC} CPP=${CXX} F77=${FC}
cp dist_est ${PREFIX}/bin
