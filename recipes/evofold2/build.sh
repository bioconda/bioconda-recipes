#!/bin/bash

mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/lib/
mkdir -p $PREFIX/include/

cp bin/* $PREFIX/bin/
cp lib/* $PREFIX/lib/
cp -R include/* $PREFIX/include/

chmod +x $PREFIX/bin/*


