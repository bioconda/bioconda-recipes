#!/bin/bash

mkdir -p $PREFIX/bin

./install.sh

mv install.sh install.sh.old

mv exe/* $PREFIX/bin

mkdir -p $PREFIX/opt/clark
mv *.sh $PREFIX/opt/clark
cd $PREFIX/opt/clark
ln -s $PREFIX/bin exe
