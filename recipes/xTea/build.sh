mkdir -p $PREFIX/bin
cp bin/xtea $PREFIX/bin
cp bin/xtea_hg19 $PREFIX/bin
mkdir -p $PREFIX/lib/xtea
cp xTea/*.{py} $PREFIX/lib/xtea/
cp -r xTea/genotyping $PREFIX/lib/xtea/