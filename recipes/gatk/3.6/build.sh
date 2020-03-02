#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

cp $RECIPE_DIR/gatk.py $PACKAGE_HOME/gatk3.py

SOURCE_FILE=$RECIPE_DIR/gatk-register.sh
DEST_FILE=$PACKAGE_HOME/gatk3-register.sh


echo "#!/bin/bash" > $DEST_FILE
echo "PKG_NAME=$PKG_NAME" >> $DEST_FILE
echo "PKG_VERSION=$PKG_VERSION" >> $DEST_FILE

cat $SOURCE_FILE >> $DEST_FILE

chmod +x $PACKAGE_HOME/*.{sh,py}

ln -s $PACKAGE_HOME/gatk3.py $PREFIX/bin/gatk3
ln -s $PACKAGE_HOME/gatk3.py $PREFIX/bin/GenomeAnalysisTK
ln -s $PACKAGE_HOME/gatk3-register.sh $PREFIX/bin/gatk3-register
