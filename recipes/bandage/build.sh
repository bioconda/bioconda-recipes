#!/bin/bash
export QT_PLUGIN_PATH=$PREFIX/plugins

mkdir -p $PREFIX/bin
qmake Bandage.pro
make

cp Bandage $PREFIX/bin/
