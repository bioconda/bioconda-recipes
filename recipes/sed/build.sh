#!/bin/bash

# fix autoconf
for f in $PREFIX/bin/autoheader $PREFIX/bin/autom4te $PREFIX/bin/autoreconf \
    $PREFIX/bin/autoscan $PREFIX/bin/autoupdate $PREFIX/bin/ifnames; do
    sed -i.bak -e '1 s|^.*$|#!/usr/bin/env perl|g' "$f"
    rm -f "$f.bak"
done

sed -i.bak -e '/^rsync .*/d' bootstrap.conf # bootstrap will fall back to wget
./bootstrap # This is needed only when the sed sources comes from the Git repo
./configure --prefix=$PREFIX
sed -i.bak -e 's/ -Wmissing-include-dirs//' Makefile
if [ $(uname -s) == 'Darwin' ]; then
    sed -i.bak -e "s|^LDFLAGS =.*|LDFLAGS = -Wl,-rpath $PREFIX/lib|" Makefile
fi
make
make install
