#!/bin/bash

sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile

sed -i.bak 's/^CPPFLAGS =$//g' htslib-1.3/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' htslib-1.3/Makefile

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make install prefix=$PREFIX
