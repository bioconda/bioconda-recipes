#!/usr/bin/env bash

BEAV_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

mkdir -p $BEAV_DIR/scripts
mkdir -p $BEAV_DIR/databases
mkdir -p $BEAV_DIR/software
mkdir -p $BEAV_DIR/models
mkdir -p $BEAV_DIR/test_data
mkdir -p $PREFIX/bin

mv beav $PREFIX/bin
mv beav_db $PREFIX/bin
mv beav_test $PREFIX/bin
mv beav_circos $PREFIX/bin
mv scripts/* $BEAV_DIR/scripts
mv databases/* $BEAV_DIR/databases
mv models/* $BEAV_DIR/models
mv test_data/* $BEAV_DIR/test_data

mv DBSCAN-SWA $BEAV_DIR/software/
mv PyCirclize $BEAV_DIR/software/
mv PaperBLAST $BEAV_DIR/software/
mkdir $BEAV_DIR/software/PaperBLAST/bin/blast

chmod +x $BEAV_DIR/scripts/*

#TIGER
#TIGER must be downloaded in the build script because the official release contains linux binaries and a broken softlink.
#Downloading in the meta.yaml script breaks the build and so it must be downloaded here with the exclude parameters.
curl -v -L -O https://github.com/sandialabs/TIGER/archive/refs/tags/TIGER2.1.tar.gz
tar xzf TIGER2.1.tar.gz --exclude 'TIGER-TIGER2.1/db/Pfam-A.hmm' --exclude 'TIGER-TIGER2.1/bin/aragorn*' --exclude 'TIGER-TIGER2.1/bin/hmmsearch' --exclude 'TIGER-TIGER2.1/bin/pfscan'
patch -p 0 -d ./ < $BEAV_DIR/scripts/tiger.patch
mv TIGER-TIGER2.1 $BEAV_DIR/software/TIGER
rm TIGER2.1.tar.gz


mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
touch $PREFIX/etc/conda/activate.d/beav_vars.sh
echo -e "#!/usr/bin/env bash" > $PREFIX/etc/conda/activate.d/beav_vars.sh
echo -e "export BEAV_DIR=$BEAV_DIR" >> $PREFIX/etc/conda/activate.d/beav_vars.sh
echo -e "export OLD_PATH=$PATH" >> $PREFIX/etc/conda/activate.d/beav_vars.sh

touch $PREFIX/etc/conda/deactivate.d/beav_vars.sh
echo -e "#!/usr/bin/env bash" > $PREFIX/etc/conda/deactivate.d/beav_vars.sh
echo -e "unset BEAV_DIR" >> $PREFIX/etc/conda/deactivate.d/beav_vars.sh
