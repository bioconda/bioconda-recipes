#!/usr/bin/bash
set -e

# Set flags conditionally based on the OS type
if [[ "$OSTYPE" != "darwin"* ]]; then
  SYSROOT_FLAGS="--sysroot=${BUILD_PREFIX}/${HOST}/sysroot"
  CPPFLAGS="${CPPFLAGS} -I${BUILD_PREFIX}/${HOST}/sysroot/usr/include ${SYSROOT_FLAGS}"
  LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -L${BUILD_PREFIX}/${HOST}/sysroot/usr/lib -L${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64 ${SYSROOT_FLAGS}"
else
  # No sysroot settings for macOS
  SYSROOT_FLAGS=""
  CPPFLAGS="${CPPFLAGS}"
  LDFLAGS="${LDFLAGS} -L${PREFIX}"
fi

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
export CPPFLAGS="${CPPFLAGS}"
export LDFLAGS="${LDFLAGS}"
export prefix="${PREFIX}"
export SYSROOT_FLAGS="${SYSROOT_FLAGS}"

if [[ "$OSTYPE" == "darwin"* ]] && [[ "$(uname -m)" == "arm64" ]]; then
  # macOS ARM64 - use new skia
  OLD_SKIA_FLAG="false"
  OLD_SKIA=0
else
  # All other platforms - use old skia
  OLD_SKIA_FLAG="true"
  OLD_SKIA=1
fi

git clone https://github.com/kcleal/gw.git
cd gw
sed -i.bak 's|$(CONDA_PREFIX)/lib -Wl|$(CONDA_PREFIX)/lib|' Makefile
$OLD_SKIA make prep
$OLD_SKIA make shared -j ${CPU_COUNT}
cp libgw/lib* "${CONDA_PREFIX}/lib"
cp -rf libgw/GW "${CONDA_PREFIX}/include"
cd ../
ls "${CONDA_PREFIX}/lib/libgw*"
ls "${CONDA_PREFIX}/include/G*"

pip install . -vv --config-settings=setup-args=-Dold_skia=${OLD_SKIA_FLAG}
