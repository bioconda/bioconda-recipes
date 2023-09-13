#!/bin/bash 

ant jar
mauve_dir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p ${mauve_dir}
cp Mauve.jar ${mauve_dir}/Mauve.jar
mkdir -v ${mauve_dir}/ext
cp -R ext/* ${mauve_dir}/ext/
cp  linux-x64/Mauve ${mauve_dir}/Mauve
cp $RECIPE_DIR/MauveCM ${mauve_dir}/MauveCM
ln -s ${mauve_dir}/Mauve $PREFIX/bin/Mauve
ln -s ${mauve_dir}/MauveCM $PREFIX/bin/MauveCM
