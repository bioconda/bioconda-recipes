#!/bin/bash
# ctat_metagenomics_DIR_NAME="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
# The above is an error. The following is correct.
ctat_metagenomics_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
ctat_metagenomics_INSTALL_PATH="$PREFIX/share/$ctat_metagenomics_DIR_NAME"
# Make the install directory and move the ctat_metagenomics files to that location.
mkdir -p $PREFIX/bin
mkdir -p $ctat_metagenomics_INSTALL_PATH
#cp -R $SRC_DIR/* $ctat_metagenomics_INSTALL_PATH
# The copy of everything does not work, because the build process puts a conda_build script
# into the same directory. That file has hard coded paths in it which are not able to be
# corrected, so the build fails.
cp -R $SRC_DIR/LICENSE.txt $SRC_DIR/metagenomics.py $SRC_DIR/README.md $SRC_DIR/SciEDPipeR $ctat_metagenomics_INSTALL_PATH
chmod a+x $ctat_metagenomics_INSTALL_PATH/metagenomics.py
cd $PREFIX/bin
# ln -s ../share/$ctat_metagenomics_DIR_NAME/metagenomics.py
# The following shell script is built to invoke metagenomics.py using its full
# install path rather than creating a symlink to it from $PREFIX/bin.
# That way the import for sciedpiper in metagenomics.py will find it, 
# because the program is invoked from its actual location.
echo "#!/bin/bash" > $PREFIX/bin/metagenomics
echo "$ctat_metagenomics_INSTALL_PATH/metagenomics.py \$@" >> $PREFIX/bin/metagenomics
chmod +x $PREFIX/bin/metagenomics
# I added the following ls commands as a way to help me understand what was happening and debug.
# I also used ls commands in the meta.yaml (since removed) in order to look at the directories.
# ls -la $PREFIX/bin
# ls -la $PREFIX/share/$ctat_metagenomics_DIR_NAME
