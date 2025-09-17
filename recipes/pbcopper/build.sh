#!/usr/bin/env bash

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig
export CXXFLAGS=$(echo "$CXXFLAGS" | sed 's/-std=c++14//g')

# configure
# '--wrap-mode nofallback' prevents meson from downloading
# stuff from the internet or using subprojects.
meson \
  --default-library static \
  --libdir lib \
  --wrap-mode nofallback \
  --prefix "${PREFIX}" \
  -Dtests=false \
  build .

# build
ninja -C build -v

# install
ninja -C build -v install
