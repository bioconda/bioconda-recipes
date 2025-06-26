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
  export OLD_SKIA=0
else
  # All other platforms - use old skia
  OLD_SKIA_FLAG="true"
  export OLD_SKIA=1
fi

export MESONPY_SETUP_ARGS="-Dold_skia=${OLD_SKIA_FLAG}"

# Subclone gw
git clone https://github.com/kcleal/gw.git

# Fetch working build script
curl -O https://raw.githubusercontent.com/kcleal/gwplot/refs/heads/main/build_gw.py
curl -O https://raw.githubusercontent.com/kcleal/gwplot/refs/heads/main/meson.build

ls

# $PYTHON -m pip wheel . --config-settings="setup-args=-Dold_skia=${OLD_SKIA_FLAG}" --no-deps

# if [[ "$OSTYPE" != "darwin"* ]]; then
#     auditwheel -v repair dist/*.whl
#     $PYTHON -m pip install wheelhouse/*.whl -v
# else
#     delocate-wheel -v dist/*.whl
#     $PYTHON -m pip install dist/*.whl -v
# fi

$PYTHON -m pip install . -vv --config-settings="setup-args=-Dold_skia=${OLD_SKIA_FLAG}"
