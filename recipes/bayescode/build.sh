#!/bin/bash

# Create bin directory
mkdir -p "${PREFIX}"/bin/

# Build PSASS specifying CPP compiler and C compiler
make CXX="${CXX}" CC="${CC}" tiny

# Copy all generated binaries to bin
cp bin/*mutselomega "${PREFIX}"/bin/
cp bin/*nodemutsel "${PREFIX}"/bin/
cp utils/*.py "${PREFIX}"/bin