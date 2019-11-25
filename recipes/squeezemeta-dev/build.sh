SQM_DIR=$PREFIX/SqueezeMeta
mkdir $SQM_DIR
cp -r $SRC_DIR/* $SQM_DIR
cd $PREFIX/bin
ln -s $SQM_DIR/scripts/SqueezeMeta.pl .
ln -s $SQM_DIR/scripts/restart.pl .
ln -s $SQM_DIR/scripts/preparing_databases/make_databases.pl .
ln -s $SQM_DIR/scripts/preparing_databases/download_databases.pl .
ln -s $SQM_DIR/scripts/preparing_databases/configure_nodb.pl .
ln -s $SQM_DIR/utils/* .
R CMD INSTALL $SQM_DIR/bin/DAS_Tool/package/DASTool_*.tar.gz
R CMD INSTALL $SQM_DIR/lib/SQMtools
