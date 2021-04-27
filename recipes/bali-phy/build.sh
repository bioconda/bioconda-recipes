#!/usr/bin/env bash

set -vex

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig

pkg-config --list-all

echo "CC=$CC"
echo "CXX=$CXX"

# configure
meson \
    --prefix="$PREFIX" \
    --buildtype=release \
    -Db_ndebug=true \
    builddir .

cd builddir

# build
meson compile

# test
meson test

# install
meson install
