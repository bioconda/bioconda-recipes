#!/usr/bin/bash
set -e

export USE_GL=1
if [[ "$OSTYPE" != "darwin"* ]]; then
  sed -i 's/-lEGL -lGLESv2/-lGL -lGLX/' Makefile
  sed -i 's/GLFW_EGL_CONTEXT_API/GLFW_NATIVE_CONTEXT_API/' src/plot_manager.cpp
fi

make prep > /dev/null 2>&1 

SYSROOT_FLAGS="--sysroot=${BUILD_PREFIX}/${HOST}/sysroot"

CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY " \
CPPFLAGS="${CPPFLAGS} -I${BUILD_PREFIX}/${HOST}/sysroot/usr/include ${SYSROOT_FLAGS} " \
LDFLAGS="${LDFLAGS} -Wl,--verbose -L${PREFIX} -L${BUILD_PREFIX}/${HOST}/sysroot/usr/lib -L${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64 ${SYSROOT_FLAGS}" \
prefix="${PREFIX}" \
make -j ${CPU_COUNT}

mkdir -p $PREFIX/bin
cp gw $PREFIX/bin/gw
cp -n .gw.ini $PREFIX/bin/.gw.ini
chmod +x $PREFIX/bin/gw
chmod +rw $PREFIX/bin/.gw.ini
