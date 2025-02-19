#!/bin/bash

export COMMIT_VERS="${PKG_VERSION}"
export COMMIT_DATE="$(date -Idate -u)"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-unused-command-line-argument"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	export CXXFLAGS="${CXXFLAGS} -fno-define-target-os-macros"
fi

if [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
	sed -i.bak -e "s/-mavx2 -mfma//" phase_common/makefile
	sed -i.bak -e "s/-mavx2 -mfma//" phase_rare/makefile
	sed -i.bak -e "s/-mavx2 -mfma//" switch/makefile
	sed -i.bak -e "s/-mavx2 -mfma//" ligate/makefile
	sed -i.bak -e "s/-mavx2 -mfma//" simulate/makefile
	sed -i.bak -e "s/-mavx2 -mfma//" xcftools/makefile
	export EXTRA_ARGS=""
else
	export EXTRA_ARGS="-mavx2 -mfma"
fi

for subdir in phase_common phase_rare switch ligate

do
    pushd $subdir

    # Build the binaries
    make \
        -j"${CPU_COUNT}" \
        DYN_LIBS="-lz -lpthread -lbz2 -llzma -lcurl -lhts -ldeflate -lm -lcrypto" \
        CXX="${CXX} -std=c++14" \
        CXXFLAG="${CXXFLAGS} ${PREFIX} -D__COMMIT_ID__='\"${COMMIT_VERS}\"' -D__COMMIT_DATE__='\"${COMMIT_DATE}\"' -Wno-ignored-attributes -O3 ${EXTRA_ARGS}" \
        LDFLAG="${LDFLAGS}" \
        HTSLIB_INC="${PREFIX}/include/htslib" \
        HTSLIB_LIB="${PREFIX}/lib/libhts.a" \
        BOOST_INC="${PREFIX}/include"\
        BOOST_LIB_IO="${PREFIX}/lib/libboost_iostreams.a" \
        BOOST_LIB_PO="${PREFIX}/lib/libboost_program_options.a" \
        BOOST_LIB_SE="${PREFIX}/lib/libboost_serialization.a" \
    ;
    # Install the binaries
    install -v -m 0755 "bin/${subdir}" "${PREFIX}/bin/SHAPEIT5_${subdir}"

    popd
done
