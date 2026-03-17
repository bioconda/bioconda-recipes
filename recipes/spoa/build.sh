#!/bin/bash
set -eoux pipefail

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I{PREFIX}/include"

case $(uname -m) in
    x86_64)
        SPOA_OPTS="-Dspoa_optimize_for_portability=ON"
        ;;
    aarch64)
        SPOA_OPTS="-Dspoa_use_simde_nonvec=ON -DBUILD_TESTING=OFF"
        ;;
    arm64)
	SPOA_OPTS="-Dspoa_use_simde_nonvec=ON -DBUILD_TESTING=OFF"
	;;
    *)
        ;;
esac

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-Dspoa_install=ON \
	-Dspoa_build_exe=ON \
	"${SPOA_OPTS}" \
	-Dspoa_use_simde=ON \
	-Dspoa_use_simde_openmp=ON \
	-Dspoa_use_cereal=ON \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" "${CONFIG_ARGS}"

cmake --build build/ --target install -j ${CPU_COUNT} -v
