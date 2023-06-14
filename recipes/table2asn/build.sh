#!/bin/bash
set -eu

gunzip *table2asn.gz
mkdir -p ${PREFIX}/bin

if [ `uname` == Darwin ]; then
	cp table2asn.mac ${PREFIX}/bin/table2asn
else
	cp *.table2asn ${PREFIX}/bin/table2asn
fi

chmod 0755 "${PREFIX}/bin/table2asn"
patchelf --replace-needed libbz2.so.1 libbz2.so.1.0 ${PREFIX}/bin/table2asn
