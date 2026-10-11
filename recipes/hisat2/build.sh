#!/bin/bash
set -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

git clone --recursive https://github.com/simd-everywhere/simde-no-tests simde

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
esac

mkdir -p "${PREFIX}/bin"

# The patch does not move the VERSION file on OSX. Let's make sure it's moved.
mv VERSION{,.txt} || true

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CPP="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
	-j"${CPU_COUNT}"

# copy binaries and python scripts
for i in \
    hisat2 \
    hisat2-align-l \
    hisat2-align-s \
    hisat2-build \
    hisat2-build-l \
    hisat2-build-s \
    hisat2-inspect \
    hisat2-inspect-l \
    hisat2-inspect-s \
    *.py
do
    install -v -m 0755 "${i}" "${PREFIX}/bin"
done
