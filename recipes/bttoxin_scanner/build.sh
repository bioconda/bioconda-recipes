#!/bin/sh
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/bin/lib

cp BtToxin_scanner.pl $PREFIX/bin/BtToxin_scanner
cp Scripts/*.pl $PREFIX/bin/
cp lib/own.pm $PREFIX/bin/lib/
cp -r BtToxinScanner_db $PREFIX/bin/BtToxinScanner_db
cp -r BtToxinScanner_models $PREFIX/bin/BtToxinScanner_models


chmod a+x $PREFIX/bin/BtToxin_scanner
chmod a+x $PREFIX/bin/coreprocess.pl
chmod a+x $PREFIX/bin/get_genes_table.pl
chmod a+x $PREFIX/bin/get_all_info_nucl.pl
chmod a+x $PREFIX/bin/get_all_info_orfs.pl
chmod a+x $PREFIX/bin/get_all_info_prot.pl
chmod a+x $PREFIX/bin/lib/own.pm


BtToxin_scanner --version
