#!/bin/bash

export DESTDIR=$PREFIX
./INSTALL
ln -s $PREFIX/usr/bin/collectl $PREFIX
ln -s $PREFIX/usr/bin/colmux $PREFIX
