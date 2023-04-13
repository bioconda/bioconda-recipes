#!/usr/bin/env bash

BEAV_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

mkdir -p $BEAV_DIR/scripts
mkdir -p $BEAV_DIR/databases
mkdir -p $BEAV_DIR/software
mkdir -p $BEAV_DIR/models
mkdir -p $BEAV_DIR/test_data

cp beav $PREFIX/bin
cp -r scripts/* $BEAV_DIR/scripts
cp -r databases/* $BEAV_DIR/databases
cp -r models/* $BEAV_DIR/models
cp -r test_data/* $BEAV_DIR/test_data

git clone https://github.com/HIT-ImmunologyLab/DBSCAN-SWA $BEAV_DIR/software/DBSCAN-SWA
chmod +x $BEAV_DIR/software/DBSCAN-SWA/bin/*
chmod +x $BEAV_DIR/software/DBSCAN-SWA/software/blast+/*
chmod +x $BEAV_DIR/software/DBSCAN-SWA/software/diamond/diamond

git clone https://github.com/morgannprice/PaperBLAST $BEAV_DIR/software/PaperBLAST
mkdir $BEAV_DIR/software/PaperBLAST/bin/blast
ln -s $PREFIX/bin/hmmsearch $BEAV_DIR/software/PaperBLAST/bin/
ln -s $PREFIX/bin/hmmfetch $BEAV_DIR/software/PaperBLAST/bin/
ln -s $PREFIX/bin/formatdb $BEAV_DIR/software/PaperBLAST/bin/blast/
ln -s $PREFIX/bin/blastall $BEAV_DIR/software/PaperBLAST/bin/blast/
ln -s $PREFIX/bin/fastacmd $BEAV_DIR/software/PaperBLAST/bin/blast/

#TIGER
curl -v -L -O https://github.com/sandialabs/TIGER/archive/refs/tags/TIGER2.1.tar.gz
tar xzf TIGER2.1.tar.gz 
mkdir $BEAV_DIR/software/TIGER
mv TIGER-TIGER2.1 $BEAV_DIR/software/TIGER
unlink $BEAV_DIR/software/TIGER/db/Pfam-A.hmm
rm TIGER2.1.tar.gz
echo "done building tiger"
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
touch $PREFIX/etc/conda/activate.d/beav_vars.sh
echo -e "#!/usr/bin/env bash" > $PREFIX/etc/conda/activate.d/beav_vars.sh
echo -e "export BEAV_DIR=$BEAV_DIR" >> $PREFIX/etc/conda/activate.d/beav_vars.sh
echo -e "export OLD_PATH=$PATH" >> $PREFIX/etc/conda/activate.d/beav_vars.sh
echo -e "export PATH=$PATH:$BEAV_DIR/software/DBSCAN-SWA/bin/:$BEAV_DIR/software/DBSCAN-SWA/software/blast+/:$BEAV_DIR/software/DBSCAN-SWA/software/diamond/" >> $PREFIX/etc/conda/activate.d/beav_vars.sh

touch $PREFIX/etc/conda/deactivate.d/beav_vars.sh
echo -e "#!/usr/bin/env bash" > $PREFIX/etc/conda/deactivate.d/beav_vars.sh
echo -e "unset BEAV_DIR" >> $PREFIX/etc/conda/deactivate.d/beav_vars.sh
echo -e "export PATH=$OLD_PATH" >> $PREFIX/etc/conda/deactivate.d/beav_vars.sh
