#!/bin/bash
FusionInspector_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
FusionInspector_INSTALL_PATH="$PREFIX/share/$FusionInspector_DIR_NAME"
# Make the install directory and move the FusionInspector files to that location.
mkdir -p $FusionInspector_INSTALL_PATH
# Split the copy into two commands for readability.
cp -R $SRC_DIR/FusionInspector $SRC_DIR/PerlLib $SRC_DIR/SciEDPipeR $SRC_DIR/FusionAnnotator $FusionInspector_INSTALL_PATH
cp -R $SRC_DIR/FusionFilter $SRC_DIR/plugins $SRC_DIR/test $SRC_DIR/util $FusionInspector_INSTALL_PATH
chmod a+x $FusionInspector_INSTALL_PATH/FusionInspector

# Find and define TRINITY_HOME
# The following assumes that Trinity was installed prior to FusionInspector.
# Look for the Trinity executable. 
# The first element in the FilesFound array should be the one that is in the bin directory.
cd $PREFIX
FilesFound=($(find . -name Trinity))
# The following gets the cannonical path of the found Trinity executable.
TRINITY_HOME=$(cd $(dirname ${FilesFound[0]}) && pwd)

# The following shell script is built to invoke FusionInspector using its full
# install path rather than creating a symlink to FusionInspector from $PREFIX/bin
# because FusionInspector uses its own location to find other scripts and packages
# which are included with it.
# It is also needed in order to set the TRINITY_HOME environment variable.
echo "#!/bin/bash" > $PREFIX/bin/FusionInspector
echo "# The FusionInspector Releases 1.1.0 and earlier require TRINITY_HOME to be defined." >> $PREFIX/bin/FusionInspector
# There is another release in the works that will not have this requirement,
# but it is not out yet.
# Define TRINITY_HOME before invoking FusionInspector.
echo "export TRINITY_HOME=\"${TRINITY_HOME}\"" >> $PREFIX/bin/FusionInspector
echo "$FusionInspector_INSTALL_PATH/FusionInspector \$@" >> $PREFIX/bin/FusionInspector
chmod +x $PREFIX/bin/FusionInspector
