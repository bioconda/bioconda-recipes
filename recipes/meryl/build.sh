#!/bin/bash

make -C src \
  BUILD_DIR="$( pwd )/build" \
  TARGET_DIR="${PREFIX}" \
  CLANG=0

rm "${PREFIX}/lib/libmeryl.a"
