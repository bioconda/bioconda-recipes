#!/bin/bash

# Create [de]activate scripts
# (ARB components expect ARBHOME set to the installation directory)

cp -a install/* $PREFIX

(
    cd $PREFIX/bin
    for binary in ../lib/arb/bin/arb*; do
	ln -s "$binary"
    done
)
