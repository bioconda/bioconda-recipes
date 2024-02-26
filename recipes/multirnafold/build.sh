# build
make CC="${CC}" CXX="${CXX}"

# install
mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/shared/${PKG_NAME}/params"
mkdir -p "$PREFIX/include"
mkdir -p "$PREFIX/lib"

cp feature_description multifold pairfold pairfold-web simfold simfold_pf "$PREFIX/bin/"
cp -r params/* "$PREFIX/shared/${PKG_NAME}/params/"
cp -r include/* "$PREFIX/include/"
cp libMultiRNAFold.a "$PREFIX/lib/"
