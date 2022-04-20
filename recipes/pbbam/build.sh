#!/usr/bin/env bash

export BOOST_ROOT="${PREFIX}"
export PKG_CONFIG_LIBDIR="${PREFIX}"/lib/pkgconfig

# required, in order to resolve otherwise undefined symbols
# - liblzma.so.5
# - libbz2.so.1.0
# - libcrypto.so.1.0.0
[[ $(uname) == Linux ]] && export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"

# The SDK is too old otherwise
if [[ $(uname) != "Linux" ]] ; then
    CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"
fi

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
