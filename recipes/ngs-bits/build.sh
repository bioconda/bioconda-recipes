#!/bin/bash

#build
CPLUS_INCLUDE_PATH=$PREFIX/include
make build_tools_release

#deploy
mkdir -p $PREFIX/bin
rm -rf bin/out bin/cpp*-TEST bin/tools-TEST
cp -r bin/* $PREFIX/bin/