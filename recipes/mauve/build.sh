#!/bin/bash 

mauve_dir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p ${mauve_dir}
cp -R * ${mauve_dir}/
cp $RECIPE_DIR/MauveCM ${mauve_dir}/MauveCM
ln -s ${mauve_dir}/Mauve $PREFIX/bin/Mauve
ln -s ${mauve_dir}/MauveCM $PREFIX/bin/MauveCM
