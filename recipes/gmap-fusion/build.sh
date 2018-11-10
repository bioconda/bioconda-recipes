#!/bin/bash
GMAP_FUSION_DIR="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
GMAP_FUSION_INSTALL_PATH="$PREFIX/share/$GMAP_FUSION_DIR"
mkdir -p $GMAP_FUSION_INSTALL_PATH
cp -R $SRC_DIR/GMAP-fusion $SRC_DIR/PerlLib $SRC_DIR/FusionFilter $SRC_DIR/DISCASM $SRC_DIR/testing $SRC_DIR/util $GMAP_FUSION_INSTALL_PATH
chmod a+x $GMAP_FUSION_INSTALL_PATH/GMAP-fusion

# The following shell script is built to invoke GMAP-fusion using its full
# install path rather than creating a symlink to GMAP-fusion from $PREFIX/bin
# because GMAP-fusion uses its own location to find other scripts and packages
# which are included with it. 
echo "#!/bin/bash" > $PREFIX/bin/GMAP-fusion
echo "$GMAP_FUSION_INSTALL_PATH/GMAP-fusion \$@" >> $PREFIX/bin/GMAP-fusion
chmod +x $PREFIX/bin/GMAP-fusion
