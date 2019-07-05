#!/bin/bash

sed -i.bak "s@\$(BAMTOOLS_PATH)lib@$PREFIX/lib@" bamdump_src/Makefile
sed -i.bak "s@\$(BAMTOOLS_PATH)include@$PREFIX/include/bamtools@" bamdump_src/Makefile
sed -i.bak "s@INCLUDES = @INCLUDES = -I$PREFIX/include @" cage_src/Makefile
sed -i.bak "s@LFLAGS = @LFLAGS = -L$PREFIX/lib -lpthread @" cage_src/Makefile
make CC=${CXX}

mkdir -p $PREFIX/bin
cp bin/cage $PREFIX/bin
cp bin/bamdump $PREFIX/bin
sed -i.bak 's@#!/anaconda/bin/python@#!/opt/anaconda1anaconda2anaconda3/bin/python@g' scripts/classify.py
cp scripts/classify.py $PREFIX/bin/cage-classify.py

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
cp scripts/*.sh $TGT
cp scripts/config_example.txt $TGT
