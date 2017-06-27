#!/bin/bash

mv . $PREFIX
mkdir $PREFIX/bin
cd $PREFIX/app
ln -s ./* ../bin/
