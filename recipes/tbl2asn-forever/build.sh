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
mv fix-sqn-date.py ${PREFIX}/bin/fix-sqn-date
chmod 755 ${PREFIX}/bin/tbl2asn
chmod 755 ${PREFIX}/bin/fix-sqn-date
