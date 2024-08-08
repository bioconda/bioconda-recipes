#!/usr/bin/bash
set -e

ldconfig -p | grep libEGL
ldconfig -p | grep libGLESv2

#ln -s /lib64/*GL* ./lib
#ls ./lib

echo "SYSROOT"
ls $CONDA_BUILD_SYSROOT

echo "TOOLCHAIN BUILD"
ls $CONDA_TOOLCHAIN_BUILD

#export USE_GL=1
if [[ "$OSTYPE" != "darwin"* ]]; then
#  sed -i 's/-lEGL -lGLESv2/-lGL/' Makefile
  LDLIBS="${LDLIBS} -lGLX"
fi
make prep > /dev/null 2>&1 

CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY" LDFLAGS="${LDFLAGS} -L${PREFIX} -L${CONDA_BUILD_SYSROOT}/lib64" prefix="${PREFIX}"  make -j ${CPU_COUNT}

mkdir -p $PREFIX/bin
cp gw $PREFIX/bin/gw
cp -n .gw.ini $PREFIX/bin/.gw.ini
chmod +x $PREFIX/bin/gw
chmod +rw $PREFIX/bin/.gw.ini

