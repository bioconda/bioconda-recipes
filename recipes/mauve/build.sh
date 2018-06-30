#!/bin/bash 

ant jar
mauve_dir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p ${mauve_dir}
cp -v Mauve.jar ${mauve_dir}/Mauve.jar
echo 'mauve_dir:'
echo ==============
ls -l ${mauve_dir}
mkdir -v ${mauve_dir}/ext
cp -vR ext/* ${mauve_dir}/ext/
echo ==============
ls -l ${mauve_dir}
cp -v linux-x64/Mauve ${mauve_dir}/Mauve
echo ==============
ls -l ${mauve_dir}
ln -s ${mauve_dir}/Mauve $PREFIX/bin/Mauve
echo ==============
ls -l ${mauve_dir}

