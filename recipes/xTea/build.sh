mkdir -p $PREFIX/bin
cp bin/xtea $PREFIX/bin
cp bin/xtea_hg19 $PREFIX/bin
mkdir -p $PREFIX/lib/xtea
cp xtea/*.{py} $PREFIX/lib/xtea/
cp -r xtea/genotyping $PREFIX/lib/xtea/
