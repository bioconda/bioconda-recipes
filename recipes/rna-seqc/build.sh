#!/bin/bash

# Setup path variables
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Create destination directories
mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

# Copy file into $PACKAGE_HOME
cp RNA-SeQC_v$PKG_VERSION.jar $PACKAGE_HOME

# Create wrapper
SOURCE_FILE=$RECIPE_DIR/rna_seqc.sh
DEST_FILE=$PACKAGE_HOME/rna-seqc

echo "#!/bin/bash" > $DEST_FILE
echo "PKG_NAME=$PKG_NAME" >> $DEST_FILE
echo "PKG_VERSION=$PKG_VERSION" >> $DEST_FILE
echo "PACKAGE_HOME=$PACKAGE_HOME" >> $DEST_FILE
cat $RECIPE_DIR/rna_seqc.sh >> $DEST_FILE

chmod +x $DEST_FILE
ln -s $DEST_FILE $PREFIX/bin