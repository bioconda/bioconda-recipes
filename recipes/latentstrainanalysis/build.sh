LSA_DIR=$PREFIX/share/LatentStrainAnalysis

mkdir -p $LSA_DIR/
cp -r ./* $PREFIX/share/LatentStrainAnalysis/
rm $LSA_DIR/testData.tar.gz

chmod +x $LSA_DIR/*.sh

mkdir -p ${PREFIX}/bin
ln -fs $LSA_DIR/KmerSVDClustering.sh  $PREFIX/bin/
ln -fs $LSA_DIR/ReadPartitioning.sh   $PREFIX/bin/
ln -fs $LSA_DIR/HashCounting.sh       $PREFIX/bin/
