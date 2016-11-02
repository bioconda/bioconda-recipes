#!/bin/bash

# fix automake
sed -i '' '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/aclocal
sed -i '' '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/automake

# fix autoconf
sed -i '' '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autom4te
sed -i '' '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoheader
sed -i '' '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoreconf
sed -i '' '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/ifnames
sed -i '' '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoscan
sed -i '' '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoupdate

# create configure file
bash ./autotools-init.sh

# run configuration
./configure --prefix=$PREFIX --with-RNA=$PREFIX

# compile and install
make clean
make
make install
