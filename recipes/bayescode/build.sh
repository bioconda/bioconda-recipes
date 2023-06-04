#!/bin/bash

rm -rf data/
# Create bin directory
mkdir -p "${PREFIX}"/bin/

# Build specifying CPP compiler and C compiler
make CXX="${CXX}" C="${CC}" tiny

# Copy all generated binaries to bin
mv bin/*mutselomega "${PREFIX}"/bin/
mv bin/node* "${PREFIX}"/bin/
mv bin/readnode* "${PREFIX}"/bin/
mv utils/*.py "${PREFIX}"/bin/