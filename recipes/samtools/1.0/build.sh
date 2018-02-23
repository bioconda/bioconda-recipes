#!/bin/sh
set -e

# remove hard-coded *flags
sed -i.bak 's/^CPPFLAGS\s*=/CPPFLAGS +=/g' Makefile
sed -i.bak 's/^LDFLAGS\s*=/LDFLAGS +=/g' Makefile
sed -i.bak 's/^CPPFLAGS\s*=/CPPFLAGS +=/g' htslib-$PKG_VERSION/Makefile
sed -i.bak 's/^LDFLAGS\s*=/LDFLAGs +=/g' htslib-$PKG_VERSION/Makefile
sed -i.bak -e 's/-lcurses/-lncurses -ltinfo/' Makefile

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make install prefix=$PREFIX
