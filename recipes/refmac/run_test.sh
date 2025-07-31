#!/bin/bash
set -exo pipefail

cd test

# Only operation check (error due to lack of monomer data)
echo -e "MAKE HYDROGENS YES\nREFI TYPE RESTA\nNCYC 10\nEND" | \
    refmac5 \
        HKLIN rnasa-1.8-all_refmac1.mtz \
        HKLOUT rnasa-1.8-all_refmac1-out.mtz \
        XYZIN tutorial-modern.pdb \
        XYZOUT tutorial-modern-ref.pdb 2>&1 || true

libcheck < /dev/null 2>&1 | grep 'LIBCHECK'
header2matr 7KNT.pdb 7KNT -B
