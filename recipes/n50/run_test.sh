#!/bin/bash
# Tests based on Debian project ncbi-blast package

set -e

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cp test.fa $TMPDIR
cd $TMPDIR

echo -n "Calculating N50 of test.fa:"
N50=$(n50 test.fa)

if [[ $N50 == '640' ]]; then
 echo " $N50 [PASS]"
else
 echo " $N50 != 640 [FAIL]"
 exit 1
fi
