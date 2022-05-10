#!/bin/bash

make -C src \
  BUILD_DIR="$( pwd )/build" \
  TARGET_DIR="${PREFIX}" \
  CC="${CC}" \
  CXX="${CXX}"

rm "${PREFIX}/lib/libmeryl.a"
