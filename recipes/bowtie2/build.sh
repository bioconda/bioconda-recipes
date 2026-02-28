#!/bin/bash -euo

# Fetch third party dependencies
# (Git submodules - https://github.com/BenLangmead/bowtie2/blob/a43fa6f43f54989468a294967898f85b9fe4cefa/.gitmodules)
git clone --branch master https://github.com/simd-everywhere/simde-no-tests.git third_party/simde
git clone https://github.com/ch4rr0/libsais third_party/libsais

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak 's|3.0.9|3.2.1|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-O2|-O3|' Makefile
case $(uname -m) in
    aarch64)
	sed -i.bak 's|-std=c++11|-std=c++14 -O3 -march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-std=c++11|-std=c++14 -O3 -march=armv8.4-a|' Makefile
	;;
    x86_64)
	sed -i.bak 's|-std=c++11|-std=c++14 -O3 -march=x86-64-v3|' Makefile
	;;
esac
rm -rf *.bak

LDFLAGS=""
make WITH_ZSTD=1 USE_SRA=1 USE_SAIS_OPENMP=1 \
	CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" CPP="${CXX}" CC="${CC}" \
	CFLAGS="${CFLAGS}" LDLIBS="-L${PREFIX}/lib -lz -lzstd -pthread"

binaries="\
bowtie2 \
bowtie2-align-l \
bowtie2-align-s \
bowtie2-build \
bowtie2-build-l \
bowtie2-build-s \
bowtie2-inspect \
bowtie2-inspect-l \
bowtie2-inspect-s \
"
directories="scripts"

for i in ${binaries}; do
    install -v -m 0755 "${i}" "${PREFIX}/bin"
done

for d in $directories; do
    cp -rf $d "${PREFIX}/bin"
done

make clean
