#!/bin/bash

set -x -e -o pipefail

echo HERE IS THE ENVIRONMENT
env
echo CXX is ${CXX}
echo version is
${CXX} --version

make -j${CPU_COUNT} DISABLE_ASMLIB=true
cp bin/kmc bin/kmc_dump bin/kmc_tools "${PREFIX}/bin/"
