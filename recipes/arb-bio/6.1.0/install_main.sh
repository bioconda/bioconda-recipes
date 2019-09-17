#!/bin/bash

# Create [de]activate scripts
# (ARB components expect ARBHOME set to the installation directory)

cp -av install/* $PREFIX

echo Creating Symlinks
(
    cd $PREFIX/bin
    for binary in ../lib/arb/bin/arb*; do
	ln -s "$binary"
	echo "  $binary"
    done
)
