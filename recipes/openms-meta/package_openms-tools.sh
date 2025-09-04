#!/bin/bash
if [[ "$target_platform" == osx-* ]]; then
  # Conda adds the $PREFIX/lib RPATH already in LDFLAGS. We could remove it there before building.
  # For now just ignore the meaningless warning.
  cmake -DCOMPONENT="Applications" -P build/cmake_install.cmake 2>&1 | grep -v "would duplicate path"
else
  cmake -DCOMPONENT="Applications" -P build/cmake_install.cmake
fi
