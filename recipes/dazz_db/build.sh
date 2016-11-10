#!/bin/bash

mkdir -p $PREFIX/bin
make

binaries="\
 fasta2DB \
 DB2fasta \
 quiva2DB \
 DB2quiva \
 DBsplit \
 DBdust \
 Catrack \
 DBshow \
 DBstats \
 DBrm \
 simulator \
 fasta2DAM \
 DAM2fasta \
 rangen \
 DBdump 
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done

