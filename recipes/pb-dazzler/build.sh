#!/bin/bash
set -vex

#export C_INCLUDE_PATH=${PREFIX}/include
#export CPLUS_INCLUDE_PATH=${PREFIX}/include
#export LD_LIBRARY_PATH=${PREFIX}/lib
#export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin

####
make -j -C DAZZ_DB

# Skip quiva2DB and DB2quiva

binaries="\
 fasta2DB \
 DB2fasta \
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
for i in $binaries; do cp DAZZ_DB/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done

####
make -j -C DALIGNER

binaries="\
 daligner  \
 HPC.daligner  \
 LAsort  \
 LAmerge  \
 LAsplit  \
 LAcat  \
 LAshow  \
 LAdump  \
 LAcheck  \
 LAindex
 DB2Falcon \
 daligner_p \
 LA4Falcon \
 LA4Ice
"

for i in $binaries; do cp DALIGNER/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done

####
make -j -C DAMASKER

binaries="\
 REPmask \
 datander \
 TANmask \
 HPC.REPmask \
 HPC.TANmask
"

for i in $binaries; do cp DAMASKER/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done

####
make -j -C DEXTRACTOR

# Skip most of DEXTRACTOR

binaries="\
 dexta  \
 undexta  \
"

for i in $binaries; do cp DEXTRACTOR/$i $PREFIX/bin; done

chmod -R a+x $PREFIX/bin
