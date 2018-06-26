#!/bin/bash
FusionInspector_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
FusionInspector_INSTALL_PATH="$PREFIX/share/$FusionInspector_DIR_NAME"
# Make the install directory and move the FusionInspector files to that location.
mkdir -p $FusionInspector_INSTALL_PATH
# Split the copy into two commands for readability.
cp -R $SRC_DIR/FusionInspector $SRC_DIR/PerlLib $SRC_DIR/PyLib $SRC_DIR/FusionAnnotator $FusionInspector_INSTALL_PATH
cp -R $SRC_DIR/FusionFilter $SRC_DIR/plugins $SRC_DIR/test $SRC_DIR/util $FusionInspector_INSTALL_PATH
chmod a+x $FusionInspector_INSTALL_PATH/FusionInspector

# Find and define TRINITY_HOME
# The following assumes that Trinity was installed prior to FusionInspector.
# And that the Trinity in the bin directory is a link.
# The install directory for Trinity when this recipe was written is within the opt directory.
# We are using the share directory for this install, which seems to be more conventional.
# Look for the Trinity executable. 
cd $PREFIX
FilesFound=($(find . -name Trinity))
# The first element in the FilesFound array may be the link that is in the bin directory,
# or it may be the actual executable.
# The order they are in the array is system dependent.
# Since do not know if the found file is the real one or the link, dereference any
# link, so we have the path to the actual executable.
TrinityFile=${FilesFound[0]}
while [[ -L ${TrinityFile} ]] ; do TrinityFile=$(readlink -f ${TrinityFile}); done
# TrinityFile should now be the actual executable.
# The following gets the cannonical path of the found Trinity executable.
TRINITY_HOME=$(cd $(dirname ${TrinityFile}) && pwd)

# The following shell script is built to invoke FusionInspector using its full
# install path rather than creating a symlink to FusionInspector from $PREFIX/bin
# because FusionInspector uses its own location to find other scripts and packages
# which are included with it.
# It is also needed in order to set the TRINITY_HOME environment variable.
echo "#!/bin/bash" > $PREFIX/bin/FusionInspector
echo "# The FusionInspector Releases 1.1.0 and earlier require TRINITY_HOME to be defined." >> $PREFIX/bin/FusionInspector
# Later releases will look for TRINITY executable in the PATH, but for now I am leaving this
# definition of TRINITY_HOME here, since it works.
# Define TRINITY_HOME before invoking FusionInspector.
echo "export TRINITY_HOME=\"${TRINITY_HOME}\"" >> $PREFIX/bin/FusionInspector
echo "$FusionInspector_INSTALL_PATH/FusionInspector \$@" >> $PREFIX/bin/FusionInspector
chmod +x $PREFIX/bin/FusionInspector
