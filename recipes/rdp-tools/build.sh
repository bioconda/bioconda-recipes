#!/bin/bash

#brew update              # [osx]
#brew install ant         # [osx]

#git config --global url."https://".insteadOf git://
#git submodule init
#git submodule update

make

mkdir -p ${PREFIX}/bin
mv *.jar ${PREFIX}/bin
mv lib ${PREFIX}/bin
