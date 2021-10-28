cd $SRC_DIR/
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
cp *.jar $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PREFIX/bin
cp $RECIPE_DIR/p2m2tools ${PREFIX}/bin
chmod 0755 ${PREFIX}/bin/p2m2tools
