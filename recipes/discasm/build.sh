#!/bin/bash
DISCASM_DIR="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
DISCASM_INSTALL_PATH="$PREFIX/share/$DISCASM_DIR"
DISCASM_PATH_FROM_BIN="../share/$DISCASM_DIR"
mkdir -p $DISCASM_INSTALL_PATH
cp -R $SRC_DIR/DISCASM $SRC_DIR/PerlLib $SRC_DIR/SciEDPipeR $SRC_DIR/testing $SRC_DIR/util $DISCASM_INSTALL_PATH
chmod a+x $DISCASM_INSTALL_PATH/DISCASM

# The following shell script is built to invoke DISCASM using its full
# install path rather than creating a symlink to DISCASM from $PREFIX/bin
# because DISCASM uses its own location to find other scripts and packages
# which are included with it.
echo "#!/bin/bash" > $PREFIX/bin/DISCASM
echo "$DISCASM_PATH_FROM_BIN/DISCASM \$@" >> $PREFIX/bin/DISCASM
chmod +x $PREFIX/bin/DISCASM

# We still need to make links to the executables in util, so that we can test that they work.
cd $PREFIX/bin
ln -s $DISCASM_PATH_FROM_BIN/util/*.pl .
ln -s $DISCASM_PATH_FROM_BIN/util/*.py .
ls -la
