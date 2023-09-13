# Build
CC=$GXX
make -e

# Install
mkdir -p $PREFIX/shared/linearfold
mkdir -p $PREFIX/bin

cp -r bin/ linearfold AUTHORS testcons $PREFIX/shared/linearfold/
ln -sr $PREFIX/shared/linearfold/linearfold $PREFIX/bin/linearfold

