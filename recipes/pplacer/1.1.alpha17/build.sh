#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR
mv guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}

# for OSX only: fix linking of dynamic libraries
if [ "$(uname)" == "Darwin" ];
then
  install_name_tool -change /usr/local/lib/libgsl.0.dylib $PREFIX/lib/libgsl.25.dylib $PREFIX/bin/pplacer
  install_name_tool -change /usr/local/lib/libgslcblas.0.dylib  $PREFIX/lib/libcblas.3.dylib $PREFIX/bin/pplacer
  install_name_tool -change /usr/local/lib/libgsl.0.dylib $PREFIX/lib/libgsl.25.dylib $PREFIX/bin/guppy
  install_name_tool -change /usr/local/lib/libgslcblas.0.dylib  $PREFIX/lib/libcblas.3.dylib $PREFIX/bin/guppy
  install_name_tool -change /usr/local/lib/libgsl.0.dylib $PREFIX/lib/libgsl.25.dylib $PREFIX/bin/rppr
  install_name_tool -change /usr/local/lib/libgslcblas.0.dylib  $PREFIX/lib/libcblas.3.dylib $PREFIX/bin/rppr
fi
