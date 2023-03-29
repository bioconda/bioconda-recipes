#!/usr/bin/env bash

set -vex

# C++20 is not properly supported on early OSX versions
case "${target_platform}" in osx-*)
    xcodebuild -sdk -version
    ${CXX} -v
esac

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig

pkg-config --list-all
pkg-config --cflags cairo

echo "CC=$CC"
echo "CFLAGS=$CFLAGS"
echo "CXX=$CXX"
echo "CPPFLAGS=$CPPFLAGS"
echo "CXXFLAGS=$CXXFLAGS"

echo "Removing -O2 and -std=c++17 from CXXFLAGS..."
CXXFLAGS="$(echo $CXXFLAGS | sed 's/-O2//g' | sed 's/-std=c++17//g')"
echo "CXXFLAGS=$CXXFLAGS"

# configure
meson setup \
    --prefix="$PREFIX" \
    --buildtype=release \
    -Db_ndebug=true \
    builddir .

cd builddir

cat meson-logs/meson-log.txt

# build
meson compile

# test
meson test

# install
meson install
