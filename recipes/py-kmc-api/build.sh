#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
esac

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-m64|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-m64|-march=armv8.4-a|' Makefile
	;;
    x86_64)
	sed -i.bak 's|-m64|-m64 -march=x86-64-v3|' Makefile
	;;
esac

sed -i.bak 's|g++-11|$(CXX)|' Makefile
sed -i.bak 's|g++|$(CXX)|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
rm -f *.bak
sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' 3rd_party/cloudflare/CMakeLists.txt
sed -i.bak 's|VERSION 2.8.12|VERSION 3.5|' 3rd_party/cloudflare/ucm.cmake
rm -f 3rd_party/cloudflare/*.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

# The vendored pybind11 predates Python 3.11; build against the packaged one.
rm -rf py_kmc_api/libs/pybind11/include
ln -s "${PREFIX}/include" py_kmc_api/libs/pybind11/include

# The work directory is reused across Python variants; start from a clean CMake cache.
rm -rf build-py

cmake -S . -B build-py -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DKMC_BUILD_PYTHON_API=ON \
	-DPython_EXECUTABLE="${PYTHON}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build-py --target py_kmc_api -j "${CPU_COUNT}"

ext_suffix=$(${PYTHON} -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))")
install -d "${SP_DIR}" "${PREFIX}/bin"
install -m 755 "$(find build-py -name 'py_kmc_api*.so' | head -n 1)" "${SP_DIR}/py_kmc_api${ext_suffix}"
install -m 755 py_kmc_api/py_kmc_dump.py "${PREFIX}/bin/py_kmc_dump.py"
