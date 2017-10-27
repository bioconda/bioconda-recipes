#!/bin/bash
ls -l
cp -r ./* $PREFIX/
mkdir $PREFIX/bin
cd $PREFIX/app
ln -s ./* ../bin/
