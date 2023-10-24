#!/usr/bin/env bash

# Change folder
cd lib

# Compile using make
make \
    F77="${FC}" \
    CPP="${CXX}"

# Change folder
cd ../src

# Compile using make
make \
    F77="${FC}" \
    CPP="${CXX}"

# Change folder
cd ..

# Copy executable to environment bin dir included in the path
mkdir -p $PREFIX/bin

chmod u+x src/discrete
cp src/discrete $PREFIX/bin/
