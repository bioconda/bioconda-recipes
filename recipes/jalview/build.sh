#!/bin/bash

# compile jalview from source
ant -DINSTALLATION="bioconda" -DJALVIEW_VERSION="$PKG_VERSION-$PKG_BUILDNUM" -Dgit.commit="" -Dgit.branch="" makedist

# create target directory
JALVIEWDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $JALVIEWDIR

# copy jalview files to target
cp -R dist/* $JALVIEWDIR/.
# copy wrapper and make executable
cp $RECIPE_DIR/jalview.sh $JALVIEWDIR/.
chmod +x $JALVIEWDIR/jalview.sh; 

# link wrapper script
mkdir -p $PREFIX/bin
ln -s $JALVIEWDIR/jalview.sh $PREFIX/bin/jalview
chmod +x $PREFIX/bin/jalview; 

