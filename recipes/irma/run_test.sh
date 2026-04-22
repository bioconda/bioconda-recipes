#!/bin/sh
set -e

TMPDIR=$(mktemp -d)
export TMP=$TMPDIR
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

TEST_FASTQ=test.fastq
cp $TEST_FASTQ $TMPDIR
cd $TMPDIR

# test IRMA runs and produces output
echo -n "Testing IRMA... "
IRMA FLU $TEST_FASTQ irma-test
test "$(ls irma-test/amended_consensus/*.fa | wc -l)" -eq 8
echo PASS

echo "ALL TESTS PASSED"
exit 0
