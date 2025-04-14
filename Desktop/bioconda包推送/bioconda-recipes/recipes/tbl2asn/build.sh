#!/bin/bash
set -e

gunzip *tbl2asn.gz
mkdir -p ${PREFIX}/bin
cp *.tbl2asn ${PREFIX}/bin/tbl2asn
chmod a+x ${PREFIX}/bin/tbl2asn
