#!/bin/bash

mkdir -p $PREFIX/bin

mkdir -p $PREFIX/opt/aquamis/

cp -r * $PREFIX/opt/aquamis/

ln -s $PREFIX/opt/aquamis/scripts/* $PREFIX/bin/

ln -s $PREFIX/opt/aquamis/aquamis.py $PREFIX/bin/aquamis

chmod -R u+x $PREFIX/bin/*
