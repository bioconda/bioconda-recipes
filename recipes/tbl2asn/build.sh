#!/bin/bash
set -e

gunzip *tbl2asn*.gz 
mkdir -p ${PREFIX}/bin
if [ -f tbl2asn.mac ]; then
	cp tbl2asn.mac ${PREFIX}/bin/tbl2asn
else
	cp *.tbl2asn ${PREFIX}/bin/tbl2asn
fi
chmod a+x ${PREFIX}/bin/tbl2asn
