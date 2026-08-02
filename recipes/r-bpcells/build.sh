#!/bin/bash

export DISABLE_AUTOBREW=1
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"
export LC_ALL="en_US.UTF-8"

mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX
CXX17=$CXX" > ~/.R/Makevars

if [[ $(uname -s) == "Darwin" ]]; then
	sed -i.bak 's|-std=c++17|-O3 -std=c++17 -D_LIBCPP_DISABLE_AVAILABILITY|' r/src/Makevars.in
	rm -f r/src/*.bak
else
	sed -i.bak 's|-std=c++17|-O3 -std=c++17|' r/src/Makevars.in
	rm -f r/src/*.bak
fi

pushd r/
${R} CMD INSTALL --build --install-tests . "${R_ARGS}"
popd
