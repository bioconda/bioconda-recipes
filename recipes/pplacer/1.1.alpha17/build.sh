#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR
mv guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}

#install_name_tool -change old new $PREFIX/bin/pplacer

install_name_tool -change /usr/lib/libz.1.dylib $PREFIX/lib/libz.1.2.13.dylib $PREFIX/bin/pplacer
install_name_tool -change /usr/lib/libsqlite3.dylib $PREFIX/lib/libsqlite3.0.dylib $PREFIX/bin/pplacer
install_name_tool -change /usr/local/lib/libgsl.25.dylib $PREFIX/lib/libgsl.25.dylib $PREFIX/bin/pplacer
install_name_tool -change /usr/local/lib/libgslcblas.0.dylib  $PREFIX/lib/libcblas.3.dylib $PREFIX/bin/pplacer
#install_name_tool -change /usr/lib/libSystem.B.dylib
install_name_tool -change /usr/local/lib/gcc/5/libgcc_s.1.dylib $PREFIX/lib/libgcc_s.1.dylib

touch $PREFIX/stefan || true
ls -la /usr/lib/libz* >> $PREFIX/stefan || true
ls -la /usr/lib/libsqlite3* >> $PREFIX/stefan || true
ls -la /usr/local/lib/libgsl* >> $PREFIX/stefan || true
ls -la /usr/local/lib/libgslcblas* >> $PREFIX/stefan || true
ls -la /usr/lib/libSystem* >> $PREFIX/stefan || true
ls -la /usr/local/lib/gcc/5/libgcc_s* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/libz* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/libsqlite3* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/libgsl* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/libgslcblas* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/libcblas* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/libSystem* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/gcc/5/libgcc* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/gcc/libgcc* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/gcc/* >> $PREFIX/stefan || true
ls -la $PREFIX/lib/libgcc* >> $PREFIX/stefan || true
#otool -L $PREFIX/bin/pplacer
#if [ $unamestr == 'Darwin' ];
#then
#	cd /usr/local/lib/; ln -s $PREFIX/lib/libgsl.25.dylib ./libgsl.0.dylib
#fi
