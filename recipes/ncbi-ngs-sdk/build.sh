NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

pushd ngs-sdk
sed -i.bak "s#gcc#${CC}#g;s#g++#${CXX}#g" setup/konfigure.perl
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --debug
make
make install
make test
popd
