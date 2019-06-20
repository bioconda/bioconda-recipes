#!/bin/bash

FGMP_HOME="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $FGMP_HOME
mkdir -p ${PREFIX}/bin

# why not use rsync?
cp -R $SRC_DIR/src ${FGMP_HOME}
cp -R $SRC_DIR/utils ${FGMP_HOME}
cp $SRC_DIR/README.md ${FGMP_HOME}
cp -R $SRC_DIR/data ${FGMP_HOME}
# fgmp.config not in source directory
# cp $SRC_DIR/fgmp.config ${FGMP_HOME}
cp -R $SRC_DIR/lib ${FGMP_HOME}
cp -R $SRC_DIR/sample ${FGMP_HOME}
cp -R $SRC_DIR/sample_output ${FGMP_HOME}

chmod -R 755 ${FGMP_HOME}/src ${FGMP_HOME}/utils ${FGMP_HOME}/lib

ln -s ${FGMP_HOME}/src/fgmp.pl ${PREFIX}/bin/fgmp
