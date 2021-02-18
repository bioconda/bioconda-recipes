#!/bin/bash

rm -f test.fna.mseq.tmp

echo -n 'Mapping gzip compressed fna file...'
mapseq test.fna.gz > test.fna.mseq.tmp 2> /dev/null

test "$(grep -c "SRR044946.2" < test.fna.mseq.tmp)" -eq 1
test "$(wc -l < test.fna.mseq.tmp)" -eq 3

echo PASS
echo
echo "ALL TESTS PASSED"
