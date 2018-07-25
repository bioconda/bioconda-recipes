#!/bin/bash

#changing arch
#adding include and library paths in order to find bzip2
sed -i.bak '
    /^PATH_INCLUDE=/ s@$@ -I'$PREFIX'/include@
    /^PATH_LIB=/ s@$@ -L'$PREFIX'/lib@
    /FLAGS_OPT=/ s@-march=native@-march=x86-64 -mtune=generic@
  ' Makefile.mk.in


./configure
make all
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
