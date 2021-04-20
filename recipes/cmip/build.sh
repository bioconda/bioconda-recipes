#!/usr/bin/env bash

# Change to src directory
cd src

# Compile using make
make \
    F77="${FC}" \
    CPP="${CXX}"

# Copy executable to environment bin dir included in the path
mkdir -p $PREFIX/bin

chmod u+x cmip
cp cmip $PREFIX/bin/

chmod u+x watden
cp watden $PREFIX/bin/

chmod u+x cavities2
cp cavities2 $PREFIX/bin/

chmod u+x cavities
cp cavities $PREFIX/bin/

chmod u+x titration
cp titration $PREFIX/bin/


cd ..
mkdir -p $PREFIX/share/cmip
cp -r dat tests wrappers scripts $PREFIX/share/cmip/
