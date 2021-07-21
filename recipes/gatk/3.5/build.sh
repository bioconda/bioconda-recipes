#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

cp $RECIPE_DIR/gatk.py $PACKAGE_HOME/gatk.py

# jar locations: Handle both nested (GATK3.8) and non-ested (<=GATK 3.7)
NESTED_GLOB="GenomeAnalysisTK-*/GenomeAnalysisTK.jar"
if compgen -G "$NESTED_GLOB"; then
  JARS=( "$NESTED_GLOB" )
  JAR=( "${JARS[0]}" )
else
  JAR=./GenomeAnalysisTK.jar
fi

mv $JAR $PACKAGE_HOME/

chmod +x $PACKAGE_HOME/*.{py,jar}

ln -s $PACKAGE_HOME/gatk.py $PREFIX/bin/gatk3
ln -s $PACKAGE_HOME/gatk.py $PREFIX/bin/GenomeAnalysisTK
