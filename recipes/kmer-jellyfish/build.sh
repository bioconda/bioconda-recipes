#!/bin/bash -euo

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-implicit-const-int-float-conversion -Wno-vla-cxx-extensio"
export CXXFLAGS="${CXXFLAGS} -O3"

cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* .

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export EXTRA_ARGS="--host=arm64"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export EXTRA_ARGS="--host=aarch64"
else
	export EXTRA_ARGS="--host=x86_64"
fi

if [[ "${OS}" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

./configure --prefix="${PREFIX}" CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" PYTHON_VERSION="${PY_VER}" \
 	--enable-python-binding="${SP_DIR}/dna_jellyfish" \
	--enable-perl-binding --with-sse --disable-option-checking \
	--enable-silent-rules --disable-dependency-tracking \
	--enable-python-deprecated "${EXTRA_ARGS}"

make -j"${CPU_COUNT}"
make install

cd swig/python
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
