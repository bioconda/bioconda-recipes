#!/bin/bash
set -xe

# add Configuration and example files to opt
export falco="$PREFIX/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $falco
cp -rf ./* $falco

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

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
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cd $falco

autoreconf -if
./configure --prefix="$falco" \
  CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
  LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
  --enable-hts --disable-option-checking \
  --enable-silent-rules --disable-dependency-tracking

make clean

make CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}";
make install

for i in $(ls -1 | grep -v Configuration | grep -v bin);
do
  rm -rf ${i};
done

install -v -m 0755 $falco/bin/falco "$PREFIX/bin"
