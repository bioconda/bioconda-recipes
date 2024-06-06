#!/usr/bin/env bash

set -vex

# C++20 is not properly supported on early OSX versions
case "${target_platform}" in osx-*)
    export MACOSX_DEPLOYMENT_TARGET=11.0
    xcodebuild -sdk -version
    ${CXX} -v
esac

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig

#pkg-config --list-all
#pkg-config --cflags cairo

echo "CC=$CC"
echo "CFLAGS=$CFLAGS"
echo "CXX=$CXX"
echo "CPPFLAGS=$CPPFLAGS"
echo "CXXFLAGS=$CXXFLAGS"

echo "Removing -mmacosx-version-min=10.9 from CPPFLAGS..."
CPPFLAGS="$(echo $CPPFLAGS | sed 's/-mmacosx-version-min=10.9/-mmacosx-version-min=11.0/g')"
echo "CPPFLAGS=$CPPFLAGS"

echo "Removing -O2 and -std=c++14 from CXXFLAGS..."
CXXFLAGS="$(echo $CXXFLAGS | sed 's/-O2//g' | sed 's/-std=c++14//g')"
echo "CXXFLAGS=$CXXFLAGS"

# configure
meson setup \
    --prefix="$PREFIX" \
    --buildtype=release \
    -Db_ndebug=true \
    builddir .

cd builddir

# cat meson-logs/meson-log.txt

# build
meson compile

# install
meson install

# check
${PREFIX}/bin/bali-phy --help
${PREFIX}/bin/bali-phy ${PREFIX}/share/doc/bali-phy/examples/5S-rRNA/5d.fasta --iter=20
