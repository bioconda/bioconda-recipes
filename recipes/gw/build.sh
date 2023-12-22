#!/usr/bin/bash
set -e
export USE_GL=1
sed -i 's/-lEGL -lGLESv2/-lGL/' Makefile
make prep
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY" make
mkdir -p $PREFIX/bin
cp gw $PREFIX/bin/gw
cp -n .gw.ini $PREFIX/bin/.gw.ini
chmod +x $PREFIX/bin/gw
chmod +rw $PREFIX/bin/.gw.ini
