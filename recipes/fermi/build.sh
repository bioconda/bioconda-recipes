#!/bin/bash
sed -i.bak "s/inline void ld_set/static inline void ld_set/g" bcr.c

autoreconf -fi
./configure --prefix="${PREFIX}"
make
make install
install run-fermi.pl "${PREFIX}/bin/"
