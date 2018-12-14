#!/bin/bash
# ctat_mutations_DIR_NAME="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
# The above is an error. The following is correct.
ctat_mutations_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
ctat_mutations_INSTALL_PATH="$PREFIX/share/$ctat_mutations_DIR_NAME"
# Make the install directory and move the ctat-mutations files to that location.
mkdir -p $PREFIX/bin
mkdir -p $ctat_mutations_INSTALL_PATH
#copy to INSTALL_PATH
cp -R $SRC_DIR/ctat_mutations $SRC_DIR/SciEDPipeR $ctat_mutations_INSTALL_PATH
#change permissions on ctat_mutations
chmod a+x $ctat_mutations_INSTALL_PATH/ctat_mutations
cd $PREFIX/bin 
echo "#!/bin/bash" > $PREFIX/bin/ctat_mutations
echo "$ctat_mutations_INSTALL_PATH/ctat_mutations \$@" >> $PREFIX/bin/ctat_mutations
chmod a+x $PREFIX/bin/ctat_mutations
