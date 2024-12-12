NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

pushd ngs/ngs-sdk
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --debug
make
make install
make test
popd
