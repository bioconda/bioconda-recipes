#!/bin/bash -euo

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

./configure --prefix="${PREFIX}" --enable-python-binding --with-sse CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"

make -j"${CPU_COUNT}"
make install
#make check -j"${CPU_COUNT}"
cd swig/python
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
