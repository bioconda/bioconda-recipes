#!/bin/sh
make release
mkdir -p $PREFIX/bin
mv stringtie $PREFIX/bin
