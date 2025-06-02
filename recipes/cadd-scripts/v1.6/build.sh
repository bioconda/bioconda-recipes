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

# Create wrappers
SOURCE_FILE=$RECIPE_DIR/cadd-wrapper.sh
DEST_FILE_CADD=$PACKAGE_HOME/cadd-wrapper.sh
DEST_FILE_INST=$PACKAGE_HOME/cadd-wrapper-install.sh

echo "#!/bin/bash" > $DEST_FILE_CADD
echo "PKG_NAME=$PKG_NAME" >> $DEST_FILE_CADD
echo "PKG_VERSION=$PKG_VERSION" >> $DEST_FILE_CADD
echo "PACKAGE_HOME=$PACKAGE_HOME" >> $DEST_FILE_CADD
cat $SOURCE_FILE >> $DEST_FILE_CADD
chmod +x $DEST_FILE_CADD
ln -s $DEST_FILE_CADD $PREFIX/bin/cadd.sh

echo "#!/bin/bash" > $DEST_FILE_INST
echo "PKG_NAME=$PKG_NAME" >> $DEST_FILE_INST
echo "PKG_VERSION=$PKG_VERSION" >> $DEST_FILE_INST
echo "PACKAGE_HOME=$PACKAGE_HOME" >> $DEST_FILE_INST
cat $SOURCE_FILE >> $DEST_FILE_INST
chmod +x $DEST_FILE_INST
ln -s $DEST_FILE_INST $PREFIX/bin/cadd-install.sh

