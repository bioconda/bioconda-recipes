#!/bin/bash

sed -i.bak -e 's|/usr/bin/g++|g++|' build/tmakelib/linux-g++-64/tmake.conf
sed -i.bak -e 's|^#!/usr/bin/perl.*$|#!/usr/bin/env perl|' bin/ht_protocol_finder.pl bin/run_rbdock.pl bin/run_rbscreen.pl bin/sdfield bin/sdfilter bin/sdmodify bin/sdreport bin/sdsort bin/sdsplit build/exemake build/p4utils.pl build/progen build/tmake lib/run_rbfuncs.pl
if [ $PY3K -eq 1 ]; then
    2to3 -w -n build/test/RBT_HOME/check_test.py
fi

cd build/
make linux-g++-64
make test

cd ..
cp bin/* "${PREFIX}/bin/"
cp lib/libRbt.* "${PREFIX}/lib/"
PERL_INSTALLSITELIB=$(perl -e 'use Config; print "$Config{installsitelib}"')
mkdir -p "${PERL_INSTALLSITELIB}"
cp lib/*.pl lib/*.pm "${PERL_INSTALLSITELIB}"
