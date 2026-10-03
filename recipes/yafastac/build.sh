#!/bin/bash

yafastac=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $yafastac
cp -rf ./* $yafastac
mkdir -p $PREFIX/bin
ln -sf $yafastac/yafastac $PREFIX/bin/yafastac
