#!/bin/bash
# Tests based on Debian project ncbi-blast package

set -e

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cp test*.fa $TMPDIR
cd $TMPDIR

echo -n 'Creating Database... '
makeblastdb \
  -in testdatabase.fa -parse_seqids -dbtype nucl -out testdb > makeblastdb.stdout
test "$(grep -c "added 3 sequences" < makeblastdb.stdout)" -eq 1
echo PASS
echo -n 'Searching Database for Hits... '
blastn \
  -query test.fa -db testdb -task blastn -dust no \
  -outfmt "7 qseqid sseqid evalue bitscore" -max_target_seqs 6 > blastn.stdout
test "$(grep -c " 3 hits found" < blastn.stdout)" -eq 1
echo PASS
echo -n 'Search and Fetch An Entry From Database... '
blastdbcmd -db testdb -entry gnl1 -out test_query.fa
test "$(grep -c ">gnl1" < test_query.fa)" -eq 1
test "$(grep -c ">" < test_query.fa)" -eq 1
test "$(wc -l < test_query.fa)" -eq 10
echo PASS
echo
echo "ALL TESTS PASSED"
