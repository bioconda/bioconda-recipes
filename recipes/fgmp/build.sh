#!/bin/bash

FGMP_HOME=$PREFIX/opt/fgmp-${PKG_VERSION}
mkdir -p $FGMP_HOME

# why not use rsync?
cp -R $SRC_DIR/src ${FGMP_HOME}
cp -R $SRC_DIR/utils ${FGMP_HOME}
cp $SRC_DIR/README.md ${FGMP_HOME}
cp -R $SRC_DIR/data ${FGMP_HOME}
cp $SRC_DIR/fgmp.config ${FGMP_HOME}
cp -R $SRC_DIR/lib ${FGMP_HOME}
cp -R $SRC_DIR/sample ${FGMP_HOME}
cp -R $SRC_DIR/sample_output ${FGMP_HOME}

chmod 755 -R ${FGMP_HOME}/src ${FGMP_HOME}/utils ${FGMP_HOME}/lib ${FGMP_HOME}/bin

ln -s ${FGMP_HOME}/src/fgmp.pl ${FGMP_HOME}/fgmp
