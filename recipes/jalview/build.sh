#!/bin/bash

# compile jalview from source
gradle -PJAVA_VERSION=1.8 -PINSTALLATION="bioconda (build $PKG_BUILDNUM)" -PJALVIEW_VERSION="$PKG_VERSION" -Pproject.ext.gitHash="" -Pproject.ext.gitBranch"" -ParchiveFileName="jalview-all-$PKG_VERSION-j1.8.jar" -PdestinationDirectory="build/libs/" shadowJar || echo faild build.

# create target directory
JALVIEWDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $JALVIEWDIR

# copy jalview files to target

# debug - is the JAR even generated ???
#ls -lR $SRC_DIR | grep jalview-all

cp -R build/libs/jalview-all-$PKG_VERSION-j1.8.jar $JALVIEWDIR/jalview-all-j1.8.jar
# copy wrapper and make executable
cp $RECIPE_DIR/jalview.sh $JALVIEWDIR/.
chmod +x $JALVIEWDIR/jalview.sh; 

# link wrapper script
mkdir -p $PREFIX/bin
ln -fs $JALVIEWDIR/jalview.sh $PREFIX/bin/jalview
chmod +x $PREFIX/bin/jalview; 

