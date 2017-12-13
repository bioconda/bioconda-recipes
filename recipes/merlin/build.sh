#!/bin/bash

mkdir -p ${PREFIX}/bin ${PREFIX}/share/doc 
export CFLAGS="-pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fPIC -fexceptions -fstack-protector --param=ssp-buffer-size=4 -O3"
make prefix=${PREFIX} bindir=${PREFIX}/bin 
make install INSTALLDIR=${PREFIX}/bin
install -m644 LICENSE.twister README ChangeLog ${PREFIX}/share/doc/
