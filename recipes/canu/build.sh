#!/bin/bash

# fail on all errors
set -e

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/lib/perl5/site_perl/canu"
mkdir -p "${PREFIX}/share/java/classes"

cp -rfv src/pipelines/canu/*.pm "${PREFIX}/lib/perl5/site_perl/canu"
cp -rfv src/mhap/mhap-2.1.3.jar "${PREFIX}/share/java/classes"

case $(uname -m) in
    aarch64)
	export ARCH="-march=armv8-a"
	;;
    arm64)
	export ARCH="-march=armv8.4-a"
	;;
    x86_64)
	export ARCH="-march=x86-64-v3"
	;;
esac

cd src
make CC="${CC} -O3" CXX="${CXX} -O3 ${ARCH} -I${PREFIX}/include" -j"${CPU_COUNT}"

cp -rfv ${SRC_DIR}/build/lib/libcanu.a "${PREFIX}/lib"

cd ../build/bin

mv canu.defaults "${PREFIX}/bin"
mv canu* draw-tig "${PREFIX}/bin"
"${STRIP}" *
install -v -m 0755 * "${PREFIX}/bin"
