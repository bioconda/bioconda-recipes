#!/bin/bash
ctat_mutations_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
ctat_mutations_INSTALL_PATH="$PREFIX/share/$ctat_mutations_DIR_NAME"
# Make the install directory and move the ctat-mutations files to that location.
mkdir -p $PREFIX/bin
mkdir -p $ctat_mutations_INSTALL_PATH
#copy to INSTALL_PATH
cp -R $SRC_DIR/ctat_mutations $ctat_mutations_INSTALL_PATH
#change permissions on ctat_mutations
chmod a+x $ctat_mutations_INSTALL_PATH/ctat_mutations
cd $PREFIX/bin
ls
echo '#!/bin/bash' > ctat_mutations
ln -s picard picard.jar
echo "export PICARD_HOME=$PREFIX/bin" >> ctat_mutations 
echo "export GATK_HOME=$PREFIX/bin" >> ctat_mutations
echo "$ctat_mutations_INSTALL_PATH/ctat_mutations \$@" >> ctat_mutations
chmod a+x ctat_mutations
