#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    sed -i.bak 's/-Wl,-soname/-Wl,-install_name/g' Makefile
    sed -i.bak 's/\.so.$(SONUMBER)/.$(SONUMBER).dylib/g' Makefile
fi

make 
cp tabix++ $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    cp libtabixpp.*.dylib ${PREFIX}/lib/
    ln -s ${PREFIX}/lib/libtabixpp.*.dylib ${PREFIX}/lib/libtabixpp.dylib 
else 
    cp libtabixpp.so.* ${PREFIX}/lib/
    ln -s ${PREFIX}/lib/libtabixpp.so.* ${PREFIX}/lib/libtabixpp.so  
fi

cp *.hpp ${PREFIX}/include
cp libtabixpp.a ${PREFIX}/lib/
