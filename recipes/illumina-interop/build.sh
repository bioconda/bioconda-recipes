#!/bin/bash
set -ex

mkdir -p "${PREFIX}/interop/bin"
mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

case $(uname -m) in
    aarch64)
		export CXXFLAGS="${CXXFLAGS} -march=armv8-a";;
    arm64)
		export CXXFLAGS="${CXXFLAGS} -march=armv8-a";;
		#export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a";;
    x86_64)
		export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3";;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DENABLE_STATIC=OFF -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}/interop" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -Wno-dev -Wno-deprecated \
	--no-warn-unused-cli -DENABLE_PYTHON=ON -DPython_EXECUTABLE="${PYTHON}" \
	-DPython_ROOT_DIR="${PREFIX}/bin" -DPYTHON_VERSION=$(python -c 'import platform; print(platform.python_version())') \
	"${CONFIG_ARGS}"

ninja -C build -j"${CPU_COUNT}" install

for FPATH in $(find ${PREFIX}/interop/bin -maxdepth 1 -mindepth 1 -type f -or -type l); do
    ln -sfvn ${FPATH} ${PREFIX}/bin/interop_$(basename ${FPATH})
done
