NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

export bCC=`basename ${CC}`
export bCXX=`basename ${CXX}`
echo "bCC ${bCC} bCXX ${bCXX}"
pushd ngs-sdk
sed -i.bak "s#gcc#${bCC}#g;s#g++#${bCXX}#g" setup/konfigure.perl
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --debug
make
make install
make test
popd
