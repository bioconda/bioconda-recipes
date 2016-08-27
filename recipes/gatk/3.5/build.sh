#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

cp $RECIPE_DIR/gatk.sh $PACKAGE_HOME/gatk.sh

SOURCE_FILE=$RECIPE_DIR/gatk-register.sh
DEST_FILE=$PACKAGE_HOME/gatk-register.sh


echo "#!/bin/bash" > $DEST_FILE
echo "PKG_NAME=$PKG_NAME" >> $DEST_FILE
echo "PKG_VERSION=$PKG_VERSION" >> $DEST_FILE

cat $SOURCE_FILE >> $DEST_FILE

chmod +x $PACKAGE_HOME/*.sh

ln -s $PACKAGE_HOME/gatk.sh $PREFIX/bin/gatk
ln -s $PACKAGE_HOME/gatk.sh $PREFIX/bin/GenomeAnalysisTK
ln -s $PACKAGE_HOME/gatk-register.sh $PREFIX/bin/gatk-register
