#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR
mv guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}

touch $PREFIX/stefan
ls -la /usr/lib/libz* >> /stefan
ls -la /usr/lib/libsqlite3* >> /stefan
ls -la /usr/local/lib/libgsl* >> /stefan
ls -la /usr/local/lib/libgslcblas* >> /stefan
ls -la /usr/lib/libSystem* >> /stefan
ls -la /usr/local/lib/gcc/5/libgcc_s* >> /stefan
#otool -L $PREFIX/bin/pplacer
#if [ $unamestr == 'Darwin' ];
#then
#	cd /usr/local/lib/; ln -s $PREFIX/lib/libgsl.25.dylib ./libgsl.0.dylib
#fi
