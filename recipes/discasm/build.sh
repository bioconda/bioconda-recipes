#!/bin/bash
DISCASM_INSTALL_DIR="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $DISCASM_INSTALL_DIR
cp -R $SRC_DIR/DISCASM $SRC_DIR/PerlLib $SRC_DIR/SciEDPipeR $SRC_DIR/testing $SRC_DIR/util $DISCASM_INSTALL_DIR
chmod a+x $DISCASM_INSTALL_DIR/DISCASM

# The following shell script is built to invoke DISCASM using its full
# install path rather than creating a symlink to DISCASM from $PREFIX/bin
# because DISCASM uses its own location to find other scripts and packages
# which are included with it.
echo "#!/bin/bash" > $PREFIX/bin/DISCASM
echo "$DISCASM_INSTALL_DIR/DISCASM \$@" >> $PREFIX/bin/DISCASM
chmod +x $PREFIX/bin/DISCASM

# We still need to make links to the executables in util, so that we can test that they work.
cd $PREFIX/bin
ln -s $DISCASM_INSTALL_DIR/util/*.pl .
ln -s $DISCASM_INSTALL_DIR/util/*.py .
