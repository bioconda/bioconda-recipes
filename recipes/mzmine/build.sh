#!/bin/bash

./gradlew

# # create target directory
# MZMINEDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
# mkdir -p $MZMINEDIR

# cp -r bin $MZMINEDIR/
# cp -r lib $MZMINEDIR/

# ln -fs $MZMINEDIR/bin/MZmine $PREFIX/bin/MZmine
# ln -fs $MZMINEDIR/bin/mzmine $PREFIX/bin/MZmine