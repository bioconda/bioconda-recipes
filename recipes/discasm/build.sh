#!/bin/bash
DISCASM_INSTALL_DIR="$PREFIX/share/DISCASM-0.1.2-0"
mkdir -p $DISCASM_INSTALL_DIR
echo "DISCASM_INSTALL_DIR is $DISCASM_INSTALL_DIR"
echo "about to copy files"
cp -R $SRC_DIR/DISCASM $SRC_DIR/PerlLib $SRC_DIR/SciEDPipeR $SRC_DIR/testing $SRC_DIR/util $DISCASM_INSTALL_DIR
chmod a+x $DISCASM_INSTALL_DIR/DISCASM
ls -la $DISCASM_INSTALL_DIR

# The following shell script is built to invoke DISCASM using its full
# install path rather than creating a symlink to DISCASM from $PREFIX/bin
# because DISCASM uses its own location to find other scripts and packages
# which are included with it.
echo "#!/bin/bash" > $PREFIX/bin/DISCASM
echo "$DISCASM_INSTALL_DIR/DISCASM \$@" >> $PREFIX/bin/DISCASM
chmod +x $PREFIX/bin/DISCASM
