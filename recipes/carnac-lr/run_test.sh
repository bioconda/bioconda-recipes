#!/bin/bash

set -e

TMPDIR=$(mktemp -d)
trap "rm -rf ${TMPDIR}" 0 INT QUIT ABRT PIPE TERM

cp test.input ${TMPDIR}
cd ${TMPDIR}

echo "Run CARNAC-LR"
CARNAC-LR -f test.input -o output.txt
echo "Test passed"
