mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/FragGeneScan/

make
make clean
make fgs

cp FragGeneScan        $PREFIX/FragGeneScan/
cp run_FragGeneScan.pl $PREFIX/FragGeneScan/
cp -r train/           $PREFIX/FragGeneScan/

ln -s $PREFIX/FragGeneScan/FragGeneScan        $PREFIX/bin/
ln -s $PREFIX/FragGeneScan/run_FragGeneScan.pl $PREFIX/bin/
ln -s $PREFIX/FragGeneScan/train/              $PREFIX/bin/train
