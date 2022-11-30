#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

sed -i '' "s|^prefix.*|prefix=$PACKAGE_HOME|g" gsea-cli.sh gsea.sh 

cp -r gsea.sh gsea-cli.sh lib modules gsea.args logging.properties $PACKAGE_HOME

ln -s $PACKAGE_HOME/gsea-cli.sh $PREFIX/bin/gsea-cli
ln -s $PACKAGE_HOME/gsea.sh $PREFIX/bin/gsea
