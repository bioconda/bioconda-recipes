#!/bin/bash

# Setup path variables
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Create destination directories
mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

# Copy file into $PACKAGE_HOME
cp -r COPYING README WekaManual.pdf changelogs data doc documentation.css documentation.html remoteExperimentServer.jar weka-src.jar weka.gif weka.ico weka.jar wekaexamples.zip $PACKAGE_HOME

# Create wrapper
SOURCE_FILE=$RECIPE_DIR/weka-dev.sh
DEST_FILE=$PACKAGE_HOME/weka-dev

echo "#!/bin/bash" > $DEST_FILE
echo "PKG_NAME=$PKG_NAME" >> $DEST_FILE
echo "PKG_VERSION=$PKG_VERSION" >> $DEST_FILE
echo "PACKAGE_HOME=$PACKAGE_HOME" >> $DEST_FILE
cat $RECIPE_DIR/weka-dev.sh >> $DEST_FILE

chmod +x $DEST_FILE
ln -s $DEST_FILE $PREFIX/bin
