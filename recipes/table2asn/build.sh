#!/bin/bash
set -e

export LD_LIBRARY_PATH="${PREFIX}/lib"

gunzip *table2asn.gz
mkdir -p ${PREFIX}/bin

if [ `uname` == Darwin ]; then
	cp table2asn.mac ${PREFIX}/bin/table2asn
else
	cp *.table2asn ${PREFIX}/bin/table2asn
fi

chmod +rx ${PREFIX}/bin/table2asn
