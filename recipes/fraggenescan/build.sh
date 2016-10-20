mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/FragGeneScan/

make
make clean
make fgs

cp FragGeneScan        $PREFIX/bin/
cp run_FragGeneScan.pl $PREFIX/bin/
cp -r train/           $PREFIX/bin/
