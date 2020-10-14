#!/bin/sh
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/bin/lib

cp BTTCMP.pl $PREFIX/bin/bttcmp
cp Scripts/*.pl $PREFIX/bin/
cp lib/own.pm $PREFIX/bin/lib/
cp -r BTTCMP_db $PREFIX/bin/BTTCMP_db
cp -r BTTCMP_models $PREFIX/bin/BTTCMP_models


chmod a+x $PREFIX/bin/bttcmp
chmod a+x $PREFIX/bin/coreprocess.pl
chmod a+x $PREFIX/bin/get_genes_table.pl
chmod a+x $PREFIX/bin/get_all_info_nucl.pl
chmod a+x $PREFIX/bin/get_all_info_orfs.pl
chmod a+x $PREFIX/bin/get_all_info_prot.pl
chmod a+x $PREFIX/bin/lib/own.pm


bttcmp --version
