#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXXFLAGS="$CXXFLAGS -I$PREFIX/include/jellyfish-2.3.1" LDFLAGS="$LDFLAGS -lroaring -lsdsl -ljellyfish-2.0 -lpthread -L${PREFIX}/lib" -f Makefile_full
cp howdesbt ${PREFIX}/bin
chmod +x ${PREFIX}/bin/howdesbt
