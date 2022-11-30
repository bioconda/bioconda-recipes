#!/bin/bash

# Following guidelines at
# https://bioconda.github.io/contributor/guidelines.html?highlight=bioconductor#java

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

# Replace the prefix to point at where we'll move files to
sed -i "s|^prefix.*|prefix=$PACKAGE_HOME|g" gsea-cli.sh gsea.sh 

# Move the files
cp -r gsea.sh gsea-cli.sh lib modules gsea.args logging.properties $PACKAGE_HOME

# Symlink from binary dir
ln -s $PACKAGE_HOME/gsea-cli.sh $BINARY_HOME/gsea-cli
ln -s $PACKAGE_HOME/gsea.sh $BINARY_HOME/gsea
