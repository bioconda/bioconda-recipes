sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoreconf

autoreconf -i
./configure --prefix=$PREFIX
make
make install
