#!/bin/bash 

ant jar
mauve_dir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
cp Mauve.jar ${mauve_dir}/
cp -R ext ${mauve_dir}/
cp Mauve ${mauve_dir}/
ln -s ${muave_dir}/Mauve $PREFIX/bin/Mauve

