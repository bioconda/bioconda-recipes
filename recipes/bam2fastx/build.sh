#!/usr/bin/env bash
set -vex

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig

pkg-config --list-all
pkg-config --cflags pbbam
pkg-config --cflags pbcopper

echo ${PREFIX}
ls -larth ${PREFIX}
ls -larth ${PREFIX}/include
ls -larth ${PREFIX}/include/pbcopper
set +e
ls -larth ${PREFIX}/include/pbcopper/cli
set -e
ls -larth ${PREFIX}/lib
ls -larth ${PREFIX}/lib/pkgconfig
cat ${PREFIX}/lib/pkgconfig/pbbam.pc
cat ${PREFIX}/lib/pkgconfig/pbcopper.pc

# configure
# '--wrap-mode nofallback' prevents meson from downloading
# stuff from the internet or using subprojects.
meson \
  --default-library shared \
  --libdir lib \
  --wrap-mode nofallback \
  --prefix "${PREFIX}" \
  -Dtests=false \
  build .

# build
ninja -C build -v

# install
ninja -C build -v install
