#!/bin/bash

set -x

# Set c++ to version 11
export CXXFLAGS="-std=c++11 ${CXXFLAGS}"

mkdir build || { echo "Failed to create build directory" >&2; exit 1; }
cd build || { echo "Failed to go into build directory" >&2; exit 1; }
cmake -G "Unix Makefiles" ..
make -j"${CPU_COUNT}" || { echo "Build failed" >&2; exit 1; }
cd .. || { echo "Failed to return to parent directory" >&2; exit 1; }
if ! ./build/bin/test_validation_suite; then
  echo "Validation suite failed" >&2
  exit 1
fi
cp build/bin/vcf_validator ${PREFIX}/bin
cp build/bin/vcf_assembly_checker ${PREFIX}/bin
echo "Done with vcf-validator"
