#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    sed -i.bak 's/-Wl,-soname/-Wl,-install_name/g' Makefile
    sed -i.bak 's/\.so.$(SONUMBER)/.$(SONUMBER).dylib/g' Makefile
fi

make 
cp tabix++ $PREFIX/bin
cp libtabixpp.so.* ${PREFIX}/lib/libtabixpp.so
cp *.hpp ${PREFIX}/include

