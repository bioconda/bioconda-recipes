#!/bin/bash

case $(uname -m) in
    x86_64)
        SPOA_OPTS="-Dspoa_optimize_for_portability=ON"
        ;;
    aarch64)
        SPOA_OPTS="-Dspoa_use_simde=ON -Dspoa_use_simde_nonvec=ON -Dspoa_use_simde_openmp=ON -DBUILD_TESTING=OFF"
        ;;
    arm64)
	SPOA_OPTS="-Dspoa_optimize_for_portability=ON"
	;;
    *)
        ;;
esac

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

mkdir -p $PREFIX/bin

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" -Dracon_build_wrapper=ON \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	"${SPOA_OPTS}" "${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}" -v

chmod +w build/bin/racon_wrapper
cp -f build/bin/racon_wrapper ${PREFIX}/bin
