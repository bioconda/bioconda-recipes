#!/bin/bash

mkdir -p ${PREFIX}/bin

# get src
wget https://github.com/kowallus/PgSA/archive/0d7c97f22a07fce96e0638deb09d2a8c05ed3d8b.zip
unzip 0d7c97f22a07fce96e0638deb09d2a8c05ed3d8b.zip

# change path to find lib
sed -i.bak 's|$(PGSA_PATH)dist/pgsalib/GNU-Linux-x86/|${PREFIX}/lib/|' Makefile
sed -i.bak 's|bin/PgSAgen|bin/PgSAgen_hgcolor|' Makefile

# change path for dependencies
sed -i.bak 's|$hgf/bin/||' HG-CoLoR
sed -i.bak 's|PgSAgen|PgSAgen_hgcolor|' HG-CoLoR
sed -i.bak 's|#!/usr/bin/python|#!/usr/bin/env python|' bin/*.py

# compilation
make PGSA_PATH=${PWD}/PgSA-0d7c97f22a07fce96e0638deb09d2a8c05ed3d8b/ CC=$CC CXX=$CXX

# copy binaries
cp bin/* ${PREFIX}/bin
cp HG-CoLoR ${PREFIX}/bin
