#!/bin/bash

# Keep track of the process
set -uex

mkdir -p $PREFIX/bin
mv * $PREFIX/bin
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"
sh ${PREFIX}/bin/install.sh

# clean up
rm -rf $PREFIX/bin/src $PREFIX/bin/*.log $PREFIX/bin/*.go $PREFIX/bin/*.yaml $PREFIX/bin/*.sh
