#!/bin/bash -ex

mkdir -p build && pushd build

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

case $(uname -m) in
    aarch64)
        ARCH_OPTS="-DHAVE_ARM8=1"
        ;;
    *)
        ARCH_OPTS="-DHAVE_SSE4_1=1"
        ;;
esac

if [ "$(uname)" == "Darwin" ]; then
        export CMAKE_EXTRA="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -Wno-dev"
else
        export CMAKE_EXTRA="-Wno-dev"
fi

cmake -S .. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=RELEASE \
	-DHAVE_TESTS=0 -DHAVE_MPI=0 "${ARCH_OPTS}" \
	-DVERSION_OVERRIDE="${PKG_VERSION}" \
	"${CMAKE_EXTRA}"

cmake --build . --target install -j ${CPU_COUNT} -v
popd
