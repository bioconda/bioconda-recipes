#!/bin/sh

./configure --prefix=$PREFIX
make

sed -i '1 s|^.*$|!# /usr/bin/env perl  -w|g' bin/autom4te
sed -i '1 s|^.*$|!# /usr/bin/env perl  -w|g' bin/autoheader
sed -i '1 s|^.*$|!# /usr/bin/env perl  -w|g' bin/autoreconf
sed -i '1 s|^.*$|!# /usr/bin/env perl  -w|g' bin/ifnames
sed -i '1 s|^.*$|!# /usr/bin/env perl  -w|g' bin/autoscan
sed -i '1 s|^.*$|!# /usr/bin/env perl  -w|g' bin/autoupdate

make install
