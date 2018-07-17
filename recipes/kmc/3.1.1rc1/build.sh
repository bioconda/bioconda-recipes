#!/bin/bash

set -x -e -o pipefail

make -j${CPU_COUNT} DISABLE_ASMLIB=true
cp bin/kmc bin/kmc_dump bin/kmc_tools "${PREFIX}/bin/"
