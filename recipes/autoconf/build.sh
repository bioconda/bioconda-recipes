#!/bin/sh

./configure --prefix=$PREFIX
make

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/autom4te
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/autoheader
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/autoreconf
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/ifnames
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/autoscan
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/autoupdate

make install
