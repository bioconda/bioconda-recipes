#!/bin/bash

export DESTDIR=$PREFIX
./INSTALL
ln -s $PREFIX/usr/bin/collectl $PREFIX/bin/
ln -s $PREFIX/usr/bin/colmux $PREFIX/bin/
