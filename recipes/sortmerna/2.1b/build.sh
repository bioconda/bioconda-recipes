mkdir -pv $PREFIX/bin
bash build.sh
cp {sortmerna,indexdb_rna} $PREFIX/bin
cp scripts/{merge-paired-reads.sh,unmerge-paired-reads.sh}  $PREFIX/bin
