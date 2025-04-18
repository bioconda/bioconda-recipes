#!bin/bash
mkdir $PREFIX/bin

chmod +x seqverify
cp seqverify $PREFIX/bin
cp seqver_functions.py $PREFIX/bin
cp seqver_plots.py $PREFIX/bin
cp seqver_lofFinder.py $PREFIX/bin
cp seqver_gtf.py $PREFIX/bin
cp seqver_genomeupdate.py $PREFIX/bin

