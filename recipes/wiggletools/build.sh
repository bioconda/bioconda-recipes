#!/bin/bash

# Patch v1.2.8 makefile; remove in next release
sed -i.orig -e 's/-L/${LDFLAGS} -L/' src/Makefile

make LIBS="-lwiggletools -lBigWig -lgsl -lgslcblas -lhts -lpthread -lm"

cp lib/libwiggletools.a $PREFIX/lib/
cp inc/wiggletools.h $PREFIX/include/
cp bin/wiggletools $PREFIX/bin/
