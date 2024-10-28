#!/bin/bash -euo

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
else
	export CXXFLAGS="${CXXFLAGS}"
fi

./configure --prefix="${PREFIX}" --enable-python-binding --with-sse CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -Wl,-rpath -Wl,${PREFIX}/lib"

make -j "${CPU_COUNT}"
make install
make check -j "${CPU_COUNT}"
cd swig/python
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
