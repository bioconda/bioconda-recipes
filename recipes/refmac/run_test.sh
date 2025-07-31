#!/bin/bash
set -exo pipefail

cd test

refmac5 \
    HKLIN   rnasa-1.8-all_refmac1.mtz \
    HKLOUT  rnasa-1.8-all_refmac1-ref.mtz \
    XYZIN   tutorial-modern.pdb \
    XYZOUT  tutorial-modern-ref.pdb > test.log

libcheck < /dev/null 2>&1 | grep 'LIBCHECK'
header2matr 7KNT.pdb 7KNT -B
