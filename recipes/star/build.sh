#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -fopenmp -Wno-register"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|-std=c++11|-std=c++14|' source/Makefile
rm -rf source/*.bak

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

if [[ "$(uname -s)" == "Darwin"  ]] && [[ "$(uname -m)" == "x86_64" ]]; then
    echo "Installing STAR for OSX."
    #install -v -m 0755 bin/MacOSX_x86_64/STAR ${PREFIX}/bin
    #install -v -m 0755 bin/MacOSX_x86_64/STARlong ${PREFIX}/bin
    cd source
    make STAR STARlong CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -DSHM_NORESERVE=0" -j"${CPU_COUNT}"
    install -v -m 0755 STAR STARlong "${PREFIX}/bin"
else
    echo "Building STAR from source"
    cd source

    AMD64_SIMD_LEVELS=("avx2" "avx" "sse4.1" "ssse3" "sse3")

    if [[ "$(uname -m)" == "x86_64" ]]; then
        for SIMD in ${AMD64_SIMD_LEVELS[@]}; do
            make STAR STARlong CXX="${CXX}" CXXFLAGSextra="-m${SIMD}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"
            cp -rf STAR ${PREFIX}/bin/STAR-${SIMD}
            cp -rf STARlong ${PREFIX}/bin/STARlong-${SIMD}
	    chmod 0755 ${PREFIX}/bin/STAR-${SIMD} ${PREFIX}/bin/STARlong-${SIMD}
            make clean
        done
        make STAR STARlong -j"${CPU_COUNT}"
        mv STAR ${PREFIX}/bin/STAR-plain
        mv STARlong ${PREFIX}/bin/STARlong-plain
        cp -f ../simd-dispatch.sh ${PREFIX}/bin/STAR
        cp -f ../simd-dispatch.sh ${PREFIX}/bin/STARlong
	chmod 0755 ${PREFIX}/bin/STAR-plain ${PREFIX}/bin/STARlong-plain
    else
        make STAR STARlong CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -DSHM_NORESERVE=0" -j"${CPU_COUNT}"
        install -v -m 0755 STAR STARlong "${PREFIX}/bin"
    fi
fi
