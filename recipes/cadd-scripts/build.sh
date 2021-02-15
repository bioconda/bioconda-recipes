#!/bin/bash

# Setup path variables
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Create destination directories
mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

# Copy files into $PACKAGE_HOME
cp -r . $PACKAGE_HOME/.

# Patch CADD.sh
sed -i -e 's/^export CADD.*/export CADD=${CADD-$(dirname "$SCRIPT")}/' $PACKAGE_HOME/CADD.sh

# Create wrapper
SOURCE_FILE=$RECIPE_DIR/cadd-wrapper.sh
DEST_FILE=$PACKAGE_HOME/cadd-wrapper.sh

echo "#!/bin/bash" > $DEST_FILE
echo "PKG_NAME=$PKG_NAME" >> $DEST_FILE
echo "PKG_VERSION=$PKG_VERSION" >> $DEST_FILE
echo "PACKAGE_HOME=$PACKAGE_HOME" >> $DEST_FILE
cat $SOURCE_FILE >> $DEST_FILE

chmod +x $DEST_FILE
ln -s $DEST_FILE $PREFIX/bin/cadd.sh
