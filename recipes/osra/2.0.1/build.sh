#!/bin/env bash

./configure --with-tclap-include=$PREFIX/include/ --with-potrace-include=$PREFIX/include/ --with-potrace-lib=$PREFIX/lib/ --with-gocr-include=$PREFIX/include/gocr/ --with-gocr-lib=$PREFIX/lib/ --with-ocrad-include=$PREFIX/include/ --with-ocrad-lib=$INSTALL_DIR/ocrad/build/lib/ --with-openbabel-include=$PREFIX/include/openbabel-2.0/ --with-openbabel-lib=$PREFIX/lib --with-graphicsmagick-lib=$PREFIX/lib/ --with-graphicsmagick-include=$PREFIX/include/GraphicsMagick/ --prefix=$PREFIX
make
make install
