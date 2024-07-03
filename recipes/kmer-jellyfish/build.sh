#!/bin/bash -euo

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Python bindings do no work on OSX
    ./configure --prefix=${PREFIX} --with-sse CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
else
    ./configure --prefix=${PREFIX} --enable-python-binding --with-sse CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
fi

make -j ${CPU_COUNT}
make check -j ${CPU_COUNT}
make install
