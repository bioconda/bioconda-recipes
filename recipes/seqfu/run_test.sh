#!/bin/bash

set -e

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cp test.fa $TMPDIR
cd $TMPDIR

# TEST N50
echo -n "[n50] Calculating N50 of test.fa:"
N50=$(n50 test.fa)

if [[ $N50 == '640' ]]; then
 echo " N50 OK: $N50 [PASS]"
else
 echo " $N50 != 640 [FAIL]"
 exit 1
fi

# TEST GREP
GREP=$(fu-grep -n gnl  test.fa | grep '>' | wc -l)
if [[ $GREP == '3' ]]; then
 echo "[fu-grep] GREP OK: $GREP [PASS]"
else
 echo "FAILED: GREP didnt retrieve 3 sequences from test.fa"
 exit 1
fi
