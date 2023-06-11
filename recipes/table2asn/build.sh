#!/bin/bash
set -e

gunzip *table2asn.gz
mkdir -p ${PREFIX}/bin
cp *.table2asn ${PREFIX}/bin/table2asn
chmod a+x ${PREFIX}/bin/table2asn
