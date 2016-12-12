#!/bin/bash
rm -rf lib/bx
rm -rf lib/bx_extras
rm -rf lib/psyco_full.py
rm -rf lib/pysam
rm -rf lib/samtools
rm -rf lib/tabix
rm -rf lib/src
$PYTHON setup.py install
# Fix strange permission issue in egg-info
find $PREFIX/lib/python*/site-packages/CrossMap*egg -type f -execdir chmod 664 {} \;
