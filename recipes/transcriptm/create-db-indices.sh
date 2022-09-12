#!/usr/bin/env bash

echo "Creating TranscriptM SortMeRNA indices..."
# TRANSCRIPTM_DATABASE is defined in build.sh, store the indices there
cd ${TRANSCRIPTM_DATABASE}

# create sortmerna index
cd 1-SortMeRNA
mkdir index

# create rRNA indices
cd rRNA_databases
for i in *.gz
do
    gunzip -f $i
done
for i in *.fasta
do
    indexdb_rna --ref $i,"${i%.*}"-db
done
cp *.dat *.stats ../index/
cd ..

# create tRNA indices
cd tRNA_databases
for i in *.gz
do
    gunzip -f $i
done
for i in *.fa
do
    indexdb_rna --ref $i,"${i%.*}"-db
done
cp *.dat *.stats ../index/
cd ..

echo "TranscriptM SortMeRNA indices are created successfully..."

exit 0
