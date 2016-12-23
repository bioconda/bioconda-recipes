export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

cd $SRC_DIR/kmer
sed -i '' -e 's/usr\/bin\/perl/usr\/bin\/env perl/g' $(find . -type f -name "*.pl")
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

