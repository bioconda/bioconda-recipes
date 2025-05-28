#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" meson setup --buildtype release \
	--prefix "${PREFIX}" --strip -Db_coverage=false \
	-Dcmake_args="${CONFIG_ARGS} -DCMAKE_POLICY_VERSION_MINIMUM=3.5" \
	build/

cd build

ninja install -v -j"${CPU_COUNT}"

# python wrappers:
${PYTHON} -m pip install "${PREFIX}/lib/btllib/python" --no-deps --no-build-isolation --no-cache-dir -vvv
