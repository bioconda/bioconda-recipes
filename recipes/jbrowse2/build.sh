#!/bin/bash

# Place the jbrowse2 www content in the conda package
mkdir -p $PREFIX/opt/jbrowse2/
cp -r * $PREFIX/opt/jbrowse2/

# Set an env var for people willing to find the jbrowse2 www content
mkdir -p $PREFIX/etc/conda/activate.d/
echo "export JBROWSE2_SOURCE_DIR=$PREFIX/opt/jbrowse2" > $PREFIX/etc/conda/activate.d/jbrowse2-sourcedir.sh
chmod a+x $PREFIX/etc/conda/activate.d/jbrowse2-sourcedir.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset JBROWSE2_SOURCE_DIR" > $PREFIX/etc/conda/deactivate.d/jbrowse2-sourcedir.sh
chmod a+x $PREFIX/etc/conda/deactivate.d/jbrowse2-sourcedir.sh

# Install the CLI
npm install --prefix=${PREFIX} -g @jbrowse/cli@${PKG_VERSION}
