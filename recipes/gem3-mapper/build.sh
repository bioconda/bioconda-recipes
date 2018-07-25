#!/bin/bash

#adding cosmetic comment to have a change last version

#adding include and library paths in order to find bzip2
sed -i.bak '
    /^PATH_INCLUDE=/ s@$@ -I'$PREFIX'/include@
    /^PATH_LIB=/ s@$@ -L'$PREFIX'/lib@
  ' Makefile.mk.in


./configure
make all
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
