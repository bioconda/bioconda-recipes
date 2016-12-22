cd $SRC_DIR/kmer
make install prefix=$PREFIX
cd $SRC_DIR/src
make
cd ../
ls

mkdir -p $PREFIX/bin
if [ `uname` == Darwin ]; then
    mv Darwin-amd64/bin/* $PREFIX/bin/
else
    mv Linux-amd64/bin/* $PREFIX/bin/
fi

