mkdir -p $PREFIX/LatentStrainAnalysis/
cp -r ./* $PREFIX/LatentStrainAnalysis/
rm $PREFIX/LatentStrainAnalysis/testData.tar.gz
chmod +x $PREFIX/LatentStrainAnalysis/*.sh

ln -s $PREFIX/LatentStrainAnalysis/KmerSVDClustering.sh $PREFIX/bin/
ln -s $PREFIX/LatentStrainAnalysis/ReadPartitioning.sh $PREFIX/bin/
ln -s $PREFIX/LatentStrainAnalysis/HashCounting.sh $PREFIX/bin/
