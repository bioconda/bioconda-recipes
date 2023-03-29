#!/usr/bin/env bash

set -vex

# C++20 is not properly supported on early OSX versions
case "${target_platform}" in osx-*)
    echo "xcodebuild -sdk -version:"
    xcodebuild -sdk -version

    echo "${CXX} -v:"
    ${CXX} -v
esac

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig

pkg-config --list-all
pkg-config --cflags cairo

echo "Before:"
echo "CC=$CC"
echo "CFLAGS=$CFLAGS"
echo "CXX=$CXX"
echo "CPPFLAGS=$CPPFLAGS"
echo "CXXFLAGS=$CXXFLAGS"
echo "LDFLAGS=$LDFLAGS"
echo "SDKROOT=$SDKROOT"

case "${target_platform}" in osx-*)
    export SDKROOT="/Applications/Xcode_14.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.sdk"

    echo "Adding -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} to CPPFLAGS, CXXFLAGS, and LDFLAGS..."

    export CPPFLAGS="$CPPFLAGS -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
    echo "CPPFLAGS=$CPPFLAGS"

    export CXXFLAGS="$CXXFLAGS -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
    echo "CXXFLAGS=$CXXFLAGS"

    export LDFLAGS="$LDFLAGS -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
    echo "LDFLAGS=$LDFLAGS"
esac

echo "Removing -O2 and -std=c++17 from CXXFLAGS..."
CXXFLAGS="$(echo $CXXFLAGS | sed 's/-O2//g' | sed 's/-std=c++17//g')"
echo "CXXFLAGS=$CXXFLAGS"

# configure
meson setup \
    --prefix="$PREFIX" \
    --buildtype=release \
    -Db_ndebug=true \
    builddir .

echo "After:"
echo "CC=$CC"
echo "CFLAGS=$CFLAGS"
echo "CXX=$CXX"
echo "CPPFLAGS=$CPPFLAGS"
echo "CXXFLAGS=$CXXFLAGS"
echo "LDFLAGS=$LDFLAGS"
echo "SDKROOT=$SDKROOT"

cd builddir

cat meson-logs/meson-log.txt

# build
meson compile

# test
meson test

# install
meson install
