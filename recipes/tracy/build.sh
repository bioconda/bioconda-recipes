#!/bin/sh

mkdir -p $PREFIX/bin
cp tracy_v*_linux_x86_64bit $PREFIX/bin/tracy
chmod 0755 ${PREFIX}/bin/tracy
