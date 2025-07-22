#!/bin/bash

# Create the directory where executables should be placed in a conda env
mkdir -p "${PREFIX}/bin"
# Optional: If you want to install header files for others to use
mkdir -p "${PREFIX}/include"
# Optional: If you want to install the static library
mkdir -p "${PREFIX}/lib"

sed -i.bak 's|ar rcs|$(AR) rcs|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-std=c11|-std=c11 -O3|' Makefile
rm -rf *.bak

make CC="${CC}" PREFIX="${PREFIX}" -j"${CPU_COUNT}"

# Install your compiled unicorn executable into that directory
install -v -m 0755 unicorn "${PREFIX}/bin"

cp -f src/unicorn.h "${PREFIX}/include"
cp -f libunicorn.a "${PREFIX}/lib"
