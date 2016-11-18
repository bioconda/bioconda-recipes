#!/bin/bash

# fix autoconf
sed -i.bak -e '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoheader \
    $PREFIX/bin/autom4te $PREFIX/bin/autoreconf $PREFIX/bin/autoscan \
    $PREFIX/bin/autoupdate $PREFIX/bin/ifnames
# fix automake
sed -i.bak -e '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/aclocal* \
    $PREFIX/bin/automake*

sed -i.bak -e '/^rsync .*/d' bootstrap.conf # bootstrap will fall back to wget
./bootstrap # This is needed only when the sed sources comes from the Git repo
./configure --prefix=$PREFIX
sed -i.bak -e 's/ -Wmissing-include-dirs//' Makefile
make
make install
