#!/bin/bash
set -xe

# add Configuration and example files to opt
falco=$PREFIX/opt/falco
mkdir -p $falco
cp -rf ./* $falco

#to fix problems with htslib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:"${PREFIX}/include"
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:"${PREFIX}/include"
export LIBRARY_PATH=$LIBRARY_PATH:"${PREFIX}/lib"
export LD_LIBRARY_PATH=$LIBRARY_PATH:"${PREFIX}/lib"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a -D_LIBCPP_DISABLE_AVAILABILITY"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3 -D_LIBCPP_DISABLE_AVAILABILITY"
	;;
esac

cd $falco

autoreconf -if
./configure --prefix="$falco" \
  --enable-hts \
  CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS}"

make -j"${CPU_COUNT}"
make install

for i in $(ls -1 | grep -v Configuration | grep -v bin);
do
  rm -rf ${i};
done

install -v -m 0755 $falco/bin/falco "$PREFIX/bin"
rm -rf bin
