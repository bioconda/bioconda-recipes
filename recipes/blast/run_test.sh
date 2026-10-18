#!/bin/bash
# Tests based on Debian project ncbi-blast package

set -eu

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" 0 INT QUIT ABRT PIPE TERM

cp test*.fa $TMPDIR
cd $TMPDIR

echo -n 'Creating Database... '
makeblastdb \
  -in testdatabase.fa -dbtype nucl -out testdb | \
   grep -q "added 3 sequences"
echo PASS

echo -n 'Checking Database integrity... '
blastdbcheck -full  -dbtype nucl -db testdb | \
   grep -q "Result=SUCCESS"
echo PASS

echo -n 'Checking database version... '
blastdbcmd -info -db testdb -dbtype nucl | \
    awk '/^BLASTDB Version/ {print $NF}' | \
    grep -q 5
echo PASS

echo -n 'Searching Database for Hits... '
blastn \
  -query test.fa -db testdb -task blastn -dust no \
  -outfmt "7 qseqid sseqid evalue bitscore" -max_target_seqs 10 | \
  grep -q " 3 hits found"
echo PASS
echo -n 'Search and Fetch An Entry From Database... '
blastdbcmd -db testdb -info | \
    grep -q "3 sequences"
echo PASS

echo -n 'Check update_blastdb.pl installation... - test -s on aarch64 until https://github.com/conda-forge/which-feedstock issue #5 is resolved' 
if [[ "$(arch)" != "aarch64" ]]; then
    perl -c `which update_blastdb.pl` >&/dev/null
    echo PASS 
else
    test -x ${PREFIX}/bin/update_blastdb.pl
    echo PASS
fi


#echo -n 'Showing available BLAST databases... '
#N=`update_blastdb.pl --showall | wc -l`
#[ $N -gt 5 ]
#echo PASS

#echo -n 'Checking get_species_taxids.sh... '
#N=`get_species_taxids.sh -t 9606 | wc -l`
#[ $N -eq 3 ]
#echo PASS
echo "ALL TESTS PASSED"
