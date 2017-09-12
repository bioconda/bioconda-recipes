#!/bin/sh
cd src
make
mkdir -p $PREFIX/bin
mv reaper $PREFIX/bin
mv tally $PREFIX/bin
mv minion $PREFIX/bin
mv swan $PREFIX/bin
