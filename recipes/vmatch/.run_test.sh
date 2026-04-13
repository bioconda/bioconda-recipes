#!/bin/bash
# Inspired from run-test.sh in package blast

set -e

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cp test*.fa $TMPDIR
cd $TMPDIR

echo -n 'Creating Database... '
mkvtree \
    -db testdatabase.fa -dna -pl 4 -allout -v | \
    grep -q "total length of sequences: 2082 (including 2 separators)"
echo PASS
# Note that we use a selection function without its full path.
# This works thanks to rpath modification by conda.
echo -n 'Searching Database for Hits... '
vmatch \
    -v -l 10 -q test.fa -selfun sel392.so 641 testdatabase.fa | \
    grep -q "640    2    0   D 640    0   0   0    0.00e+00 1280   100.00"
echo PASS
echo -n 'Search and Fetch An Entry From Database... '
vseqselect -minlength 700 testdatabase.fa > test_query.fa
test "$(grep -c ">gnl1" < test_query.fa)" -eq 1
test "$(grep -c ">" < test_query.fa)" -eq 2
test "$(wc -l < test_query.fa)" -eq 26
echo PASS
echo
echo "ALL TESTS PASSED"
