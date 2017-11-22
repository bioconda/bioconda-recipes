#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/pgsa_src

# get src and compile libPgSA
wget https://github.com/kowallus/PgSA/archive/0d7c97f22a07fce96e0638deb09d2a8c05ed3d8b.zip
unzip 0d7c97f22a07fce96e0638deb09d2a8c05ed3d8b.zip
cd PgSA-0d7c97f22a07fce96e0638deb09d2a8c05ed3d8b

make build CONF=pgsalib
cp dist/pgsalib/*/libPgSA.so ${PREFIX}/lib

# return to working dir
cd ..

# change path to find lib
sed -i.bak 's|$(PGSA_PATH)dist/pgsalib/GNU-Linux-x86/|${PREFIX}/lib/|' Makefile

# change path for dependencies
sed -i.bak 's|$hgf/bin/||' HG-CoLoR

# compilation
ABSOLUTE_PGSA_PATH=`pwd`
make PGSA_PATH=${ABSOLUTE_PGSA_PATH}/PgSA-0d7c97f22a07fce96e0638deb09d2a8c05ed3d8b/

# copy binaries
cp bin/* ${PREFIX}/bin
cp HG-CoLoR ${PREFIX}/bin
