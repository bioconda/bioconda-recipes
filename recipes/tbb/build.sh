#!/usr/bin/env bash

rsync -aPq "include/tbb" "$INCLUDE_PATH"
rsync -aPq "include/serial" "$INCLUDE_PATH"

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  # On Linux, there's more variability, so lets build from scratch
  make -j$CPU_COUNT prefix=$PREFIX
  mkdir -p $LIBRARY_PATH && cp build/linux*_release/*.so* $LIBRARY_PATH
fi
if [ "$(uname -s)" == "Darwin" ]; then
  # On OSX, just copy the pre-built binaries
  DYNAMIC_EXT="dylib"
  rsync -aPq lib/*.dylib ${LIBRARY_PATH}
fi

