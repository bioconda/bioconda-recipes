#! /bin/bash
mkdir -p $PREFIX/bin
make CC=${CC}
cp mreps $PREFIX/bin
