#!/usr/bin/env bash

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig

# configure
meson \
  --default-library static \
  --libdir lib \
  --prefix "${PREFIX}" \
  -Dtests=false \
  build .

# build
ninja -C build -v

# install
ninja -C build -v install
