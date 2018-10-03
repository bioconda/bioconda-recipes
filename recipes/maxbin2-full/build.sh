ls -l
cd src
make
cd ../

# building auxiliary packages
./autobuild_auxiliary > errors


# copying over all necessary files
mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/bin/src/

cp bacar_marker.hmm $PREFIX/bin/
cp buildapp $PREFIX/bin/
cp _getabund.pl $PREFIX/bin/
cp _getmarker.pl $PREFIX/bin/
cp heatmap.r $PREFIX/bin/
cp marker.hmm $PREFIX/bin/
cp run_MaxBin.pl $PREFIX/bin/
cp _sepReads.pl $PREFIX/bin/
cp -r src/MaxBin $PREFIX/bin/src/
