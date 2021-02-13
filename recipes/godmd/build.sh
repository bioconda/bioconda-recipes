#!/usr/bin/env bash

# Compile using make
make \
    F77="${FC}" \
    CPP="${CXX}"

# Copy executable to environment bin dir included in the path
mkdir -p $PREFIX/bin

chmod u+x discrete/discrete
cp discrete/discrete $PREFIX/bin/
