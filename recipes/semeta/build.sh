make clean
make

INSTALL_DIR=$CONDA_PREFIX/share/SeMeta-1.0/
mkdir -p $INSTALL_DIR

cp SeMeta_Assign $INSTALL_DIR
cp SeMeta_Cluster $INSTALL_DIR
cp config.conf $INSTALL_DIR
cp README.txt $INSTALL_DIR

ln -s $INSTALL_DIR/SeMeta_Assign $CONDA_PREFIX/bin/
ln -s $INSTALL_DIR/SeMeta_Cluster $CONDA_PREFIX/bin/
