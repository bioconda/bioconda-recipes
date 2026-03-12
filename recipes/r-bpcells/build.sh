#!/bin/bash

export DISABLE_AUTOBREW=1
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"
export LC_ALL="en_US.UTF-8"

if [[ $(uname -s) == "Darwin" ]]; then
  sed -i.bak 's|-std=c++17|-O3 -std=c++17 -D_LIBCPP_DISABLE_AVAILABILITY|' r/src/Makevars.in
  rm -rf r/src/*.bak
else
  sed -i.bak 's|-std=c++17|-O3 -std=c++17|' r/src/Makevars.in
  rm -rf r/src/*.bak
fi

pushd r/
${R} CMD INSTALL --build --install-tests . "${R_ARGS}"
popd
