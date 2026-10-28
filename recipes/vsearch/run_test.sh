#!/bin/bash
# Tests if vsearch can read gz files

# remove output file
rm -f tmp.fna

echo -n 'Open a compressed .fna.gz file...'
vsearch --derep_fulllength small.fna.gz --output tmp.fna
test "$(grep -c "TGCTGCCTCCCGTAGGAGTTTGGGCCGTGTCTCAG" < tmp.fna)" -eq 1
test "$(wc -l < tmp.fna)" -eq 2
echo PASS
echo
echo "ALL TESTS PASSED"
