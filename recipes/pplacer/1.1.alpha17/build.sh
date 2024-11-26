#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR
mv guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}

touch $PREFIX/stefan || true
ls -la /usr/lib/libz* >> $PREFIX/stefan || true
ls -la /usr/lib/libsqlite3* >> $PREFIX/stefan || true
ls -la /usr/local/lib/libgsl* >> $PREFIX/stefan || true
ls -la /usr/local/lib/libgslcblas* >> $PREFIX/stefan || true
ls -la /usr/lib/libSystem* >> $PREFIX/stefan || true
ls -la /usr/local/lib/gcc/5/libgcc_s* >> $PREFIX/stefan || true
#otool -L $PREFIX/bin/pplacer
#if [ $unamestr == 'Darwin' ];
#then
#	cd /usr/local/lib/; ln -s $PREFIX/lib/libgsl.25.dylib ./libgsl.0.dylib
#fi
