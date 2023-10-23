#!/bin/bash
  
BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/opt/$PKG_NAME

mkdir -p ${BINARY_HOME}
mkdir -p ${PACKAGE_HOME}


JAR_NAME=GAMETES_2.1.jar

cp ${JAR_NAME} ${PACKAGE_HOME}/GAMETES_2.1.jar
cp $RECIPE_DIR/gametes.py ${BINARY_HOME}/gametes
#ln -s ${PACKAGE_HOME}/gametes.py ${BINARY_HOME}/gametes

chmod +x ${PACKAGE_HOME}/
chmod +x ${BINARY_HOME}/gametes


