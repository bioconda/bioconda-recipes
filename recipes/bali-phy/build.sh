#!/usr/bin/env bash

set -vex

# Show the compiler used for the C++23 build on macOS.
case "${target_platform}" in osx-*)
    ${CXX} -v
esac

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"

# Require Cairo support in the package; Meson otherwise silently disables it.
pkg-config --cflags --libs cairo

echo "CC=$CC"
echo "CFLAGS=$CFLAGS"
echo "CXX=$CXX"
echo "CPPFLAGS=$CPPFLAGS"
echo "CXXFLAGS=$CXXFLAGS"

# Compatibility workaround retained from 4.2 for libc++ availability annotations.
# Revisit when the macOS SDK/deployment target permits removing it.
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# configure
meson setup \
    --prefix="$PREFIX" \
    --buildtype=release \
    --wrap-mode=nodownload \
    -Db_ndebug=true \
    builddir .

cd builddir

# cat meson-logs/meson-log.txt

# build
meson compile

# install
meson install
