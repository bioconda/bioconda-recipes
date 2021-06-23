#!/bin/bash

# Adapted from https://github.com/bioconda/bioconda-recipes/blob/master/recipes/blast/run_test.sh

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

TEST_FASTA=test1.fa
TEST_FASTQ=test2.fastq

cp $TEST_FASTA $TEST_FASTQ $TMPDIR
cd $TMPDIR

echo -n "Testing LABEL... "
LABEL $TEST_FASTA label-test H9v2011
grep -q "GQ373074" label-test_final.txt
grep -q "EF154979" label-test_final.txt
echo PASS

echo -n "Testing IRMA... "
IRMA FLU test2.fastq irma-test
# fasta files for each of the 8 segments of influenza
test "$(ls irma-test/amended_consensus/*.fa | wc -l)" -eq 8
echo PASS
echo 
echo "ALL TESTS PASSED"
exit 0
