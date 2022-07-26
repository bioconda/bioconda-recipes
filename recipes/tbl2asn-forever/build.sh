#!/bin/sh

mkdir -p $PREFIX/bin

if [ "$(uname)" == "Darwin" ]; then
    # OSX
    mv tbl2asn/tbl2asn-25.7-osx ${PREFIX}/bin/real-tbl2asn
else
    # Linux
    mv tbl2asn/tbl2asn-25.7-linux ${PREFIX}/bin/real-tbl2asn
fi

mv tbl2asn-forever ${PREFIX}/bin/tbl2asn
mv tbl2asn-test ${PREFIX}/bin/tbl2asn-test
mv fix-sqn-date.py ${PREFIX}/bin/fix-sqn-date
chmod 755 ${PREFIX}/bin/tbl2asn
chmod 755 ${PREFIX}/bin/tbl2asn-test
chmod 755 ${PREFIX}/bin/fix-sqn-date

# Build libfaketime
FAKETIME_COMPILE_CFLAGS='-DFORCE_MONOTONIC_FIX'
export FAKETIME_COMPILE_CFLAGS
cd libfaketime
make
make test
make install PREFIX=$PREFIX
cd ..
