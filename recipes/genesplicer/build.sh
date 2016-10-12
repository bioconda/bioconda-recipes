mkdir -p $PREFIX/bin $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
cd sources/ && make
rm -rf ../bin/*
mv genesplicer ../ && cd ../
cp -r * $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/genesplicer $PREFIX/bin