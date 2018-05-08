#!/bin/bash
# ctat_mutations_DIR_NAME="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
# The above is an error. The following is correct.
ctat_mutations_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
ctat_mutations_INSTALL_PATH="$PREFIX/share/$ctat_mutations_DIR_NAME"
# Make the install directory and move the ctat_mutations files to that location.
mkdir -p $PREFIX/bin
mkdir -p $ctat_mutations_INSTALL_PATH
#cp -R $SRC_DIR/* $ctat_mutations_INSTALL_PATH
# The copy of everything does not work, because the build process puts a conda_build script
# into the same directory. That file has hard coded paths in it which are not able to be
# corrected, so the build fails.
cp -R $SRC_DIR/LICENSE.txt $SRC_DIR/rnaseq_mutation_pipeline.py $SRC_DIR/README.md $SRC_DIR/SciEDPipeR $ctat_mutations_INSTALL_PATH
chmod a+x $ctat_mutations_INSTALL_PATH/rnaseq_mutation_pipeline.py
cd $PREFIX/bin
# ln -s ../share/$ctat_mutations_DIR_NAME/rnaseq_mutation_pipeline.py
# The following shell script is built to invoke rnaseq_mutation_pipeline.py using its full
# install path rather than creating a symlink to it from $PREFIX/bin.
# That way the import for sciedpiper in rnaseq_mutation_pipeline.py will find it, 
# because the program is invoked from its actual location.
echo "#!/bin/bash" > $PREFIX/bin/mutations
echo "$ctat_mutations_INSTALL_PATH/rnaseq_mutation_pipeline.py \$@" >> $PREFIX/bin/mutations
chmod +x $PREFIX/bin/mutations
# I added the following ls commands as a way to help me understand what was happening and debug.
# I also used ls commands in the meta.yaml (since removed) in order to look at the directories.
# ls -la $PREFIX/bin
# ls -la $PREFIX/share/$ctat_mutations_DIR_NAME
