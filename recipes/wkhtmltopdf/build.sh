#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/share/man/man1/


mv bin/* $PREFIX/bin/
mv include/wkhtmltox/ $PREFIX/include/
mv lib/* $PREFIX/lib/
mv share/man/man1/* $PREFIX/share/man/man1/
