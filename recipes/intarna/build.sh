#!/bin/bash

# suppress warnings and add -fopenmp to compilation due to viennarna setup
export LDFLAGS="${LDFLAGS} -Wl,-rpath ${PREFIX}/lib";
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include";
export CXXFLAGS="${CXXFLAGS} -O3 -w -fopenmp";

if [[ `uname -s` == "Darwin" ]] ; then
	export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
	export LDFLAGS="${LDFLAGS} -stdlib=libc++"
	export extra_config_options="${extra_config_options} --disable-pkg-config"
else  ## linux
	export CXXFLAGS="${CXXFLAGS}"
fi

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

./configure --prefix="${PREFIX}" \
	--with-vrna="${PREFIX}" \
	--with-boost="${PREFIX}" \
	--with-zlib="${PREFIX}" \
	--disable-log-coloring \
	--with-boost-libdir="${PREFIX}/lib" \
	--disable-intarnapvalue \
	CXX="${CXX}" \
	${extra_config_options}


make -j"${CPU_COUNT}"

if [[ `uname -s` != "Darwin" ]]; then  # skip tests for osx to avoid timeout
	make tests -j"${CPU_COUNT}"
fi
make install
