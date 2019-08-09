#!/bin/bash
DISCASM_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
DISCASM_INSTALL_PATH="$PREFIX/share/$DISCASM_DIR_NAME"
mkdir -p $DISCASM_INSTALL_PATH
cp -R $SRC_DIR/DISCASM $SRC_DIR/PerlLib $SRC_DIR/PyLib $SRC_DIR/testing $SRC_DIR/util $DISCASM_INSTALL_PATH
chmod a+x $DISCASM_INSTALL_PATH/DISCASM

# The following shell script is built to invoke DISCASM using its full
# install path rather than creating a symlink to DISCASM from $PREFIX/bin
# because DISCASM uses its own location to find other scripts and packages
# which are included with it.
echo "#!/bin/bash" > $PREFIX/bin/DISCASM
echo "$DISCASM_INSTALL_PATH/DISCASM \$@" >> $PREFIX/bin/DISCASM
chmod +x $PREFIX/bin/DISCASM
