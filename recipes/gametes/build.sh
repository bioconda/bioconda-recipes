#create target directory
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PACKAGE_HOME

#create bin
BINARY_HOME=$PREFIX/bin
mkdir -p $BINARY_HOME

cd $SRC_DIR

JAR_NAME=GAMETES_2.1.jar

cp $JAR_NAME $PACKAGE_HOME/gametes.jar

#mv wrapper script to package home 
cp $RECIPE_DIR/gametes.py $PACKAGE_HOME

#and symlink to $PREFIX/bin
#ln -s $PACKAGE_HOME/gametes.py  ${BINARY_HOME}
ln -s $PACKAGE_HOME/gametes.py $BINARY_HOME/gametes

#chmod +x ${BINARY_HOME}
chmod +x ${BINARY_HOME}/gametes

