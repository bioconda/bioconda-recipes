#!/bin/bash

# Create bin directory
mkdir -p "${PREFIX}"/bin/

# Build PSASS specifying CPP compiler and C compiler
make CXX="${CXX}" CC="${CC}" tiny

# Copy all generated binaries to bin
cp bin/*mutselomega "${PREFIX}"/bin/
cp bin/node* "${PREFIX}"/bin/
cp bin/readnode* "${PREFIX}"/bin/
cp utils/*.py "${PREFIX}"/bin