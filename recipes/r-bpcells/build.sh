#!/bin/bash

export DISABLE_AUTOBREW=1
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"
export LC_ALL="en_US.UTF-8"

if [[ $(uname -s) == "Darwin" ]] ; then
  sed -i.bak 's|$CXXFLAGS $LDFLAGS $HWY_CFLAGS|$CXXFLAGS -O3 -D_LIBCPP_DISABLE_AVAILABILITY -std=libc++ $LDFLAGS $HWY_CFLAGS|' r/configure
  rm -rf r/*.bak
fi

pushd r/
${R} CMD INSTALL --build --install-tests . "${R_ARGS}"
popd
