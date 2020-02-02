#!/bin/bash
mkdir -p ${PREFIX}/bin
make CXXFLAGS="$CXXFLAGS -I$PREFIX/include/jellyfish-2.3.0" LDFLAGS="$LDFLAGS -lroaring -lsdsl -ljellyfish-2.0 -lpthread"
cp howdesbt ${PREFIX}/bin
chmod +x ${PREFIX}/bin/howdesbt
