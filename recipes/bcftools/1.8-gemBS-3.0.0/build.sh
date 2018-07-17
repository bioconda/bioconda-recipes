#!/bin/sh

export CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export CFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

#modify the build command to point to the correct relative folder
for mkFile in gemBSsrc/tools/gemBS_plugins/{mextr.mk,snpxtr.mk}; do
  sed -i.bak '
      s@../gemBS@gemBSsrc/tools/gemBS@g
    ' $mkFile
done

#include the plugins
ln -sf ../gemBSsrc/tools/gemBS_plugins/{mextr.c,mextr.mk,snpxtr.c,snpxtr.mk} plugins/


./configure --prefix=$PREFIX --enable-libcurl CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
make all
make install
