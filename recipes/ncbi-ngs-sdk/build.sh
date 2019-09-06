NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

sed -i.bak "349i\
\$TOOLS = '${CXX}';" setup/konfigure.perl

pushd ngs-sdk
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --debug
make
make install
make test
popd
