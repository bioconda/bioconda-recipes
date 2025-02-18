#!/usr/bin/env bash

# MITOSALT_DATA is defined in build.sh, store the db there
echo "Downloading MITOSALT database to ${MITOSALT_DATA}..."


cd ${MITOSALT_DATA}

# Set variables
HG19_URL=https://www.dropbox.com/s/e1xwzye9hieewxz/human_g1k_v37.fasta.gz
HG19_V=hg19_g1k.fasta
MTRCRS_V=human_mt_rCRS.fasta
HG19S_V=hg19_g1k.size
M38_URL=ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/635/GCF_000001635.26_GRCm38.p6/GCF_000001635.26_GRCm38.p6_genomic.fna.gz
M38_V=mm10.fasta
MTM_V=mouse_mt.fasta
M38S_V=mm10.size
TMPFILE=tmp_file

# Download human genome and extract mt genome 
wget -O $TMPFILE $HG19_URL
gunzip -c $TMPFILE > genome/$HG19_V
faSize -detailed genome/$HG19_V|egrep -v 'GL|MT' > genome/$HG19S_V
rm $TMPFILE
echo 'MT' > tmp.txt
faSomeRecords genome/$HG19_V tmp.txt genome/$MTRCRS_V
rm tmp.txt

#BUILD HUMAN INDEXES
hisat2-build -p 2 genome/$HG19_V genome/hg19_g1k
lastdb -uNEAR  genome/human_mt_rCRS genome/$MTRCRS_V
samtools faidx genome/$HG19_V
samtools faidx genome/$MTRCRS_V

# Download mouse genome and extract mt genome 
wget -O $TMPFILE $M38_URL
gunzip -c $TMPFILE > genome/$M38_V
faSize -detailed genome/$M38_V|fgrep NC|fgrep -v 'NC_005089.1' > genome/$M38S_V
rm $TMPFILE
echo 'NC_005089.1' > tmp.txt
faSomeRecords genome/$M38_V tmp.txt genome/$MTM_V
rm tmp.txt

echo "MITOSALT database is downloaded."

echo "Create indices..."

# Build human index 
hisat2-build -p 4 genome/$HG19_V genome/hg19_g1k
lastdb -uNEAR  genome/human_mt_rCRS genome/$MTRCRS_V
samtools faidx genome/$HG19_V
samtools faidx genome/$MTRCRS_V

# Build mouse index 
hisat2-build -p 4 genome/$M38_V genome/mm10
lastdb -uNEAR  genome/mouse_mt genome/$MTM_V
samtools faidx genome/$M38_V
samtools faidx genome/$MTM_V

echo "Indices are created."

exit 0
