#!/bin/bash

# Setup path variables
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Create destination directories
mkdir -p $PACKAGE_HOME
mkdir -p ${PREFIX}/bin

# Copy files over into $PACKAGE_HOME
cp -aR * $PACKAGE_HOME

# Create wrappers
SOURCE_FILE=$RECIPE_DIR/run-jaffa.sh
for suffix in direct assembly hybrid; do
    DEST_FILE=$PACKAGE_HOME/jaffa-$suffix

    echo "#!/bin/bash" > $DEST_FILE
    echo "PKG_NAME=$PKG_NAME" >> $DEST_FILE
    echo "PKG_VERSION=$PKG_VERSION" >> $DEST_FILE
    echo "PACKAGE_HOME=$PACKAGE_HOME" >> $DEST_FILE
    echo "RUNMODE=$suffix" >>$DEST_FILE
    cat $SOURCE_FILE >> $DEST_FILE

    chmod +x $DEST_FILE
    ln -s $DEST_FILE $PREFIX/bin
done
