#!/bin/bash

# Install additional dependencies
if [ -z ${OSX_ARCH+x} ]; then
  ./install_dependencies.sh linux
else
  ./install_dependencies.sh osx
fi
mkdir build || { echo "Failed to create build directory" >&2; exit 1; }
cd build || { echo "Failed to go into build directory" >&2; exit 1; }
cmake -G "Unix Makefiles" ..
make -j2 || { echo "Build failed" >&2; exit 1; }
cd .. || { echo "Failed to return to parent directory" >&2; exit 1; }
if ! ./build/bin/test_validation_suite; then
  echo "Validation suite failed" >&2
  exit 1
fi
echo "Done with vcf-validator"
