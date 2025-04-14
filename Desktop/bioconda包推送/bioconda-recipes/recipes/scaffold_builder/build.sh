#!/bin/bash

scaffold_builder_dir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $scaffold_builder_dir
cp -r ./* $scaffold_builder_dir

mkdir -p $PREFIX/bin

ln -s $scaffold_builder_dir/scaffold_builder.py $PREFIX/bin/scaffold_builder.py
