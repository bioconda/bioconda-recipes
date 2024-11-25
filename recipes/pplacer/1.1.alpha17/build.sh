#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR
cp guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}

if [ $unamestr == 'Darwin' ];
then
	cd /usr/local/lib/; ln -s $PREFIX/lib/libgsl.25.dylib ./libgsl.0.dylib
fi
