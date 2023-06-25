#!/usr/bin/env bash

BEAV_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

mkdir -p $BEAV_DIR/scripts
mkdir -p $BEAV_DIR/databases
mkdir -p $BEAV_DIR/software
mkdir -p $BEAV_DIR/models
mkdir -p $BEAV_DIR/test_data
mkdir -p $PREFIX/bin

cp beav $PREFIX/bin
cp beav_db $PREFIX/bin
cp -r scripts/* $BEAV_DIR/scripts
cp -r databases/* $BEAV_DIR/databases
cp -r models/* $BEAV_DIR/models
cp -r test_data/* $BEAV_DIR/test_data

git clone https://github.com/weisberglab/DBSCAN-SWA $BEAV_DIR/software/DBSCAN-SWA

git clone https://github.com/weisberglab/PaperBLAST $BEAV_DIR/software/PaperBLAST
mkdir $BEAV_DIR/software/PaperBLAST/bin/blast

#TIGER
curl -v -L -O https://github.com/sandialabs/TIGER/archive/refs/tags/TIGER2.1.tar.gz
tar xzf TIGER2.1.tar.gz --exclude 'TIGER-TIGER2.1/db/Pfam-A.hmm' --exclude 'TIGER-TIGER2.1/bin/aragorn*' --exclude 'TIGER-TIGER2.1/bin/hmmsearch' --exclude 'TIGER-TIGER2.1/bin/pfscan'
patch -p 0 -d ./ < scripts/tiger.patch
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
