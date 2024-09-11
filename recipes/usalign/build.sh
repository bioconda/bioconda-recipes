#!/bin/bash

set -exuo pipefail

cd "${SRC_DIR}"
"${CXX}" -O3 -ffast-math USalign.cpp -o USalign -lm

install -d "${PREFIX}/bin"
install USalign "${PREFIX}/bin/"
