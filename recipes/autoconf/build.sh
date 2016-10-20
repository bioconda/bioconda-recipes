#!/bin/sh

./configure --prefix=$PREFIX
make

sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' bin/autom4te
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' bin/autoheader 
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' bin/autoreconf 
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' bin/ifnames 
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' bin/autoscan 
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' bin/autoupdate

make install
