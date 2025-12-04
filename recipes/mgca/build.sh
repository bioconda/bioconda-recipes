#!/bin/sh
mkdir -p $PREFIX/bin

cp mgca.pl $PREFIX/bin/mgca
cp Scripts/setupDB.pl $PREFIX/bin/setupDB
cp Scripts/pI/print_pI.pl $PREFIX/bin/
cp Scripts/pI/plot_pI.R $PREFIX/bin/
cp Scripts/IS/run_islandpath.pl $PREFIX/bin/
cp Scripts/PROPHAGE/run_PhiSpy.pl $PREFIX/bin/
cp Scripts/CRISPR/run_opfi.py $PREFIX/bin/
cp Scripts/CRISPR/db/cas_all_* $PREFIX/bin/
cp Scripts/CRISPR/db/cas1_db.* $PREFIX/bin/


chmod a+x $PREFIX/bin/mgca
chmod a+x $PREFIX/bin/setupDB
chmod a+x $PREFIX/bin/print_pI.pl
chmod a+x $PREFIX/bin/plot_pI.R
chmod a+x $PREFIX/bin/run_islandpath.pl
chmod a+x $PREFIX/bin/run_PhiSpy.pl
chmod a+x $PREFIX/bin/run_opfi.py
chmod a+x $PREFIX/bin/cas_all_*
chmod a+x $PREFIX/bin/cas1_db.*


mgca --version
mgca --help
