
#!/bin/bash
# fix automake
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/aclocal
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/automake

# fix autoconf
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autom4te
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoheader
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoreconf
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/ifnames
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoscan
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoupdate

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin


./bootstrap.sh
./configure --prefix=$PREFIX --with-gsl=$PREFIX 
make
make install 
