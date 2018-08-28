#!/usr/bin/env bash

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig

if [[ ${OSTYPE} == darwin* ]]; then
	export LDFLAGS+="-Wl,-headerpad_max_install_names"
fi

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
