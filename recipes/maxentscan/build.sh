mkdir -p $PREFIX/bin
cp score3.pl $PREFIX/bin/maxentscan_score3.pl
cp score5.pl $PREFIX/bin/maxentscan_score5.pl
cp -r splicemodels $PREFIX/bin
chmod 0755 $PREFIX/*
