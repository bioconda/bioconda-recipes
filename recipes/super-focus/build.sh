#!/bin/bash
superfocus_dir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $superfocus_dir
cp -r ./* $superfocus_dir
mkdir -p $PREFIX/bin
ln -s $superfocus_dir/superfocus.py $PREFIX/bin/superfocus.py
ln -s $superfocus_dir/superfocus_downloadDB.py $PREFIX/bin/superfocus_downloadDB.py
ln -s $superfocus_dir/focus/focus.py $PREFIX/bin/focus.py
