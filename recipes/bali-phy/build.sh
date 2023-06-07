#!/usr/bin/env bash

set -vex

# C++20 is not properly supported on early OSX versions
case "${target_platform}" in osx-*)
    export MACOSX_SDK_VERSION="13.1"
    export MACOSX_DEPLOYMENT_TARGET="13.1"

    echo "xcodebuild -sdk -version:"
    xcodebuild -sdk -version

    echo "xcodebuild -showsdks:"
    xcodebuild -showsdks

    echo "xcodebuild -sdk macosx -show-sdk-path:"
    xcodebuild -sdk macosx -show-sdk-path

    # Select the latest SDK
    export SDKROOT=$(xcodebuild -sdk macosx -show-sdk-path)
    echo "SDKROOT=$SDKROOT"

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
echo "MACOSX_SDK_VERSION=${MACOSX_SDK_VERSION}"
echo "MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"

case "${target_platform}" in osx-*)
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
echo "MACOSX_SDK_VERSION=${MACOSX_SDK_VERSION}"
echo "MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"

cd builddir

cat meson-logs/meson-log.txt

# build
meson compile

# test
meson test

# install
meson install
