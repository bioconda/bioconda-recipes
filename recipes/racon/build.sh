#!/bin/bash

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

case $(uname -m) in
    x86_64)
        export SPOA_OPTS="-Dspoa_optimize_for_portability=ON"
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
        ;;
    aarch64)
        export SPOA_OPTS="-Dspoa_optimize_for_native=ON -Dspoa_use_simde=ON -Dspoa_use_simde_nonvec=ON -Dspoa_use_simde_openmp=ON -DBUILD_TESTING=OFF"
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
        ;;
    arm64)
	export SPOA_OPTS="-Dspoa_optimize_for_native=ON -Dspoa_use_simde=ON -Dspoa_use_simde_nonvec=ON -Dspoa_use_simde_openmp=ON -DBUILD_TESTING=OFF"
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    *)
        ;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -Dracon_build_wrapper=ON \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${SPOA_OPTS}" \
	"${CONFIG_ARGS}"

ninja -C build -j "${CPU_COUNT}" install

install -v -m 0755 build/bin/racon_wrapper "${PREFIX}/bin"
