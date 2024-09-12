#!/usr/bin/bash
set -e

# Get pre-compiled skia from jetbrains
# USE_GL=1 make prep > /dev/null 2>&1 
# Build skia from scratch
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i.bak 's/skia_use_metal=true//g' ./deps/build_skia.sh
fi
# Use gn from conda
sed -i.bak 's/bin\/gn/gn/g' ./deps/build_skia.sh

bash ./deps/build_skia.sh


if [[ "$OSTYPE" != "darwin"* ]]; then
  sed -i 's/-lEGL -lGLESv2/-lEGL -lGLESv2 -lGL -lGLX/' Makefile
  sed -i 's/GLFW_EGL_CONTEXT_API/GLFW_NATIVE_CONTEXT_API/' src/plot_manager.cpp
fi

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

CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY" \
CPPFLAGS="${CPPFLAGS}" \
LDFLAGS="${LDFLAGS}" \
prefix="${PREFIX}" \
make -j ${CPU_COUNT}

mkdir -p $PREFIX/bin
cp gw $PREFIX/bin/gw
cp -n .gw.ini $PREFIX/bin/.gw.ini
chmod +x $PREFIX/bin/gw
chmod +rw $PREFIX/bin/.gw.ini
