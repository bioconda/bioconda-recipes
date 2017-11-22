#!/bin/bash

mkdir -p ${PREFIX}/bin

make build CONF=pgsalib
make PGSA_PATH=$PREFIX

# change path to find dependencies
sed -i.bak 's|(PGSA_PATH)dist/pgsalib/GNU-Linux-x86/|(PGSA_PATH)/bin/|' Makefile
sed -i.bak 's|(PGSA_PATH)src|(PGSA_PATH)/include|' Makefile

# change path for find dependencies
sed -i.bak 's|$hgf/bin/||' HG-CoLoR

cp bin/* ${PREFIX}/bin
cp HG-CoLoR ${PREFIX}/bin
