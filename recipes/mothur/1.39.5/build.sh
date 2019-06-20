mkdir -pv $PREFIX/bin/blast/bin
make -j 2
cp {mothur,uchime} $PREFIX/bin
ln -s $PREFIX/bin/{bl2seq,formatdb,blastall,megablast} $PREFIX/bin/blast/bin/
