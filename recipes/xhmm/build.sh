mkdir -p $PREFIX/bin
cd $SRC_DIR/build 
make
cp ./xhmm $PREFIX/bin
