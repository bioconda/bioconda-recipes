NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

pushd ngs-sdk
sed -i.bak "349i\
\$TOOLS = '${CXX}';" setup/konfigure.perl
sed -i.bak "414,415d" setup/konfigure.perl
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --debug
make
make install
make test
popd
