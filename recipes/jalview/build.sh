#!/bin/bash

# patch jalview 2.11.0 gradle.properties so the shadowJar task generates jars called jalview-all-2.11.0-j{11,1.8}.jar
echo "rootProject.name = 'jalview'" >> settings.gradle

# compile jalview from source

# First the Java 1.8 build
gradle -PJAVA_VERSION=1.8 -PINSTALLATION="bioconda (build $PKG_BUILDNUM)" -PJALVIEW_VERSION="$PKG_VERSION" -Pproject.ext.gitHash="" -Pproject.ext.gitBranch"" shadowJar 

# copy jalview jar to target
cp -vR build/libs/jalview-all-$PKG_VERSION-j1.8.jar $JALVIEWDIR/jalview-all-j1.8.jar

# Now the Java 11 build
gradle -PJAVA_VERSION=11 -PINSTALLATION="bioconda (build $PKG_BUILDNUM)" -PJALVIEW_VERSION="$PKG_VERSION" -Pproject.ext.gitHash="" -Pproject.ext.gitBranch"" shadowJar 

# copy jalview jar to target
cp -vR build/libs/jalview-all-$PKG_VERSION-j11.jar $JALVIEWDIR/jalview-all-j11.jar

# create target directory
JALVIEWDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $JALVIEWDIR



# copy wrapper and make executable
cp $RECIPE_DIR/jalview.sh $JALVIEWDIR/.
chmod +x $JALVIEWDIR/jalview.sh; 

# link wrapper script
mkdir -p $PREFIX/bin
ln -fs $JALVIEWDIR/jalview.sh $PREFIX/bin/jalview
chmod +x $PREFIX/bin/jalview; 

