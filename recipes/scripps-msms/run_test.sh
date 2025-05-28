#!/usr/bin/env bash

set -euo pipefail

echo "### Testing pdb_to_xyzr"
cat 1crn.pdb | pdb_to_xyzr > out.xyzr
if grep -qF "12.703    4.973   10.746 1.40" out.xyzr; then
  echo "pdb_to_xyzr: OK"
else
  echo "pdb_to_xyzr: FAILED"
  exit 1
fi

echo "### Testing pdb_to_xyzrn"
cat 1crn.pdb | pdb_to_xyzrn > out.xyzrn
if grep -qF "12.703000 4.973000 10.746000 1.400000 1 OXT_ASN_46" out.xyzrn; then
  echo "pdb_to_xyzrn: OK"
else
  echo "pdb_to_xyzrn: FAILED"
  exit 1
fi

echo "### Testing msms surface generation"
msms -if 1crn.xyzr -of 1crn
if grep -qF "25.578    13.692     9.815" 1crn.vert && \
   grep -qF "1302   1306   1309  1   1304" 1crn.face; then
  echo "msms: OK"
else
  echo "msms: FAILED"
  exit 1
fi

echo "ALL TESTS PASSED"
