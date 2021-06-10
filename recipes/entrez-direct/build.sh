#!/bin/bash

mkdir -p $PREFIX/bin
mv * $PREFIX/bin
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"
sh ${PREFIX}/bin/setup.sh

# clean up
rm -rf $PREFIX/bin/src $PREFIX/bin/*.log $PREFIX/bin/*.go $PREFIX/bin/*.yaml $PREFIX/bin/*.sh
