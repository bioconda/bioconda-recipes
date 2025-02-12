#!/bin/bash

case $(uname -m) in
    x86_64)
        SPOA_OPTS="-Dspoa_optimize_for_portability=ON"
        ;;
    aarch64)
        SPOA_OPTS="-Dspoa_use_simde=ON -Dspoa_use_simde_nonvec=ON -Dspoa_use_simde_openmp=ON"
        ;;
    arm64)
	SPOA_OPTS="-Dspoa_use_simde=ON -Dspoa_use_simde_nonvec=ON -Dspoa_use_simde_openmp=ON"
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
rm -rf build

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DRAVEN_BUILD_EXE=ON \
	-DCMAKE_INSTALL_PREFIX="$PREFIX" "${SPOA_OPTS}" \
	"${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}" -v

install -v -m 0755 build/bin/raven $PREFIX/bin
