#!/bin/bash
# ctat_lncrna_DIR_NAME="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
# The above is an error. The following is correct.
ctat_lncrna_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
ctat_lncrna_INSTALL_PATH="$PREFIX/share/$ctat_lncrna_DIR_NAME"
# Make the install directory and move the ctat_lncrna files to that location.
mkdir -p $PREFIX/bin
mkdir -p $ctat_lncrna_INSTALL_PATH
#copy to INSTALL_PATH
cp -R $SRC_DIR/lncrna $SRC_DIR/SciEDPipeR $ctat_lncrna_INSTALL_PATH
#change permissions on lncrna
chmod a+x $ctat_lncrna_INSTALL_PATH/lncrna
cd $PREFIX/bin 
echo "#!/bin/bash" > $PREFIX/bin/lncrna
echo "$ctat_lncrna_INSTALL_PATH/lncrna \$@" >> $PREFIX/bin/lncrna
chmod a+x $PREFIX/bin/lncrna
