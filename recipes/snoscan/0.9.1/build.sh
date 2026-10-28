#!/bin/bash
set -eu

export LC_ALL="en_US.UTF-8"

mkdir -p "$PREFIX/bin"

sed -i.bak 's|CC = cc|CC ?= cc|' Makefile
sed -i.bak 's|-O2|-O3|' Makefile

sed -i.bak 's|CC = cc|CC ?= cc|' squid-1.5.11/Makefile
sed -i.bak 's|-O2|-O3|' squid-1.5.11/Makefile
sed -i.bak 's|AR     = ar rcv|#AR     = ar rcv|' squid-1.5.11/Makefile
sed -i.bak 's|$(AR)|$(AR) rcs|' squid-1.5.11/Makefile

rm -f *.bak squid-1.5.11/*.bak

make -C squid-1.5.11 clean
make clean

make -C squid-1.5.11 -j"${CPU_COUNT}"
make

mv sort-snos sort-snos.pl

## Build Perl

mkdir -p perl-build

find . -name '*.pl' ! -path './perl-build/*.pl' -exec mv {} perl-build \;

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' perl-build/*.pl
rm -f perl-build/*.bak

cd perl-build
cp -f ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..
## End build perl

ln -sf "$PREFIX/bin/sort-snos.pl" "$PREFIX/bin/sort-snos"

cp -f snoscan "$PREFIX/bin/snoscanA"
cp -f snoscan "$PREFIX/bin/snoscanH"
cp -f snoscan "$PREFIX/bin/snoscanY"
install -v -m 0755 snoscan scan-yeast "$PREFIX/bin"

chmod +rx "$PREFIX/bin/genpept2gsi.pl"
chmod +rx "$PREFIX/bin/genbank2gsi.pl"
chmod +rx "$PREFIX/bin/swiss2gsi.pl"
chmod +rx "$PREFIX/bin/fasta2gsi.pl"
chmod +rx "$PREFIX/bin/pir2gsi.pl"
chmod +rx "$PREFIX/bin/sort-snos.pl"
