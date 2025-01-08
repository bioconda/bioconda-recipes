#!/usr/bin/env bash

set -vex

# C++20 is not properly supported on early OSX versions
case "${target_platform}" in osx-*)
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

CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"   # for std::filesystem::path

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
