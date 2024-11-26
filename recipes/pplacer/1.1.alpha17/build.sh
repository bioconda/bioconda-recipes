#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR
mv guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}


if [ $unamestr == 'Darwin' ];
then
  for binary in guppy pplacer rppr; do
	install_name_tool -change /usr/lib/libsqlite3.dylib $PREFIX/lib/libsqlite3.0.dylib $PREFIX/bin/$binary;
	install_name_tool -change /usr/local/lib/libgsl.0.dylib $PREFIX/lib/libgsl.25.dylib $PREFIX/bin/$binary;
	install_name_tool -change /usr/local/lib/libgslcblas.0.dylib  $PREFIX/lib/libcblas.3.dylib $PREFIX/bin/$binary;
	install_name_tool -change /usr/local/lib/gcc/5/libgcc_s.1.dylib $PREFIX/lib/libgcc_s.1.dylib $PREFIX/bin/$binary;
  done;
fi
