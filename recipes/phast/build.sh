#!/bin/sh

echo "COMPILER"
gcc=$CC

# Create bin folder
mkdir -p $PREFIX/bin

# PHAST requires CLAPACK to be installed with the default directory structure
# CLAPACK conda package does not follow this structure and it's easier to
# download and compile CLAPACK from source
wget http://www.netlib.org/clapack/clapack.tgz
tar -xf clapack.tgz
cd CLAPACK-3.2.1
cp make.inc.example make.inc && make CC=$CC f2clib && make CC=$CC blaslib && make CC=$CC lib

# Installing PHAST
cd ../src

# PHAST needs a path to Clapack libraries at compile time
make CC=$CC CLAPACKPATH=$SRC_DIR/CLAPACK-3.2.1

# PHAST builds multiple binaries
cd ..
chmod +x bin/*
mv bin/* $PREFIX/bin
