#!/bin/bash 

ant jar
mauve_dir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
cp -v Mauve.jar ${mauve_dir}/
echo 'mauve_dir:'
echo ==============
ls -l ${mauve_dir}
cp v-R ext ${mauve_dir}/
echo ==============
ls -l ${mauve_dir}
cp -v Mauve ${mauve_dir}/
echo ==============
ls -l ${mauve_dir}
ln -s ${muave_dir}/Mauve $PREFIX/bin/Mauve

