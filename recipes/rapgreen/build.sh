#!/bin/bash

set -eux -o pipefail

# Prepare share folder 
RAPGREEN_DIR=${PREFIX}/share/RapGreen
mkdir -p ${RAPGREEN_DIR}

# take care of the jar and copy it into the share folder
mkdir -p "$PREFIX/bin"
cp -rf ${SRC_DIR}/bin/* ${RAPGREEN_DIR}

# Handle python wrapper script that will call the jar file
cp ${RECIPE_DIR}/rapgreen.py ${RAPGREEN_DIR}/rapgreen.py
ln -s ${RAPGREEN_DIR}/rapgreen.py ${PREFIX}/bin/rapgreen

# Make executable in the share folder
chmod +x ${RAPGREEN_DIR}/*

#BINARY_HOME=$PREFIX/bin 
#RAP_GREEN_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Copy source to the conda environment
#mkdir -p $PREFIX/bin



#mkdir -p $PREFIX/share
#mkdir -p $RAP_GREEN_HOME


#cp -rf bin/RapGreen.jar $PREFIX/bin

#cp -R $SRC_DIR/* $RAP_GREEN_HOME/

# Create symbolic links for a5_miseq's launch script
#mkdir -p $BINARY_HOME
#ln -s $RAP_GREEN_HOME/bin/RapGreen.jar $BINARY_HOME/ 





#Old script

#outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
#mkdir -p $outdir
#mkdir -p $PREFIX/bin
#cp "$PREFIX/bin/RapGreen.jar "$outdir/"
#chmod 0755 "${PREFIX}/bin/RapGreen.jar"

#ln -s "$outdir/rapgreen" "$PREFIX/bin"
