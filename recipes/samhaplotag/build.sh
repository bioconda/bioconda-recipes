#!/bin/bash

set -eo pipefail

if [ `uname` == Darwin ]; then
    meson setup --buildtype=release --prefix=$PREFIX --unity on builddir
else
    env CXX=clang meson setup --buildtype=release --prefix=$PREFIX --unity on builddir
fi

cd builddir
meson compile
meson test
meson install

