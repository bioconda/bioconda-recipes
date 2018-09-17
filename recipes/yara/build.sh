#!/bin/bash
set -eu -o pipefail

mkdir build
cd build

cmake .. -DSEQAN_BUILD_SYSTEM=APP:yara -DSEQAN_ARCH_NATIVE=ON -DCMAKE_INSTALL_PREFIX=$PREFIX
make all
make test
make install
