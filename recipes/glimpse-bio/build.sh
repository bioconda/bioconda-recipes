#!/bin/bash

export COMMIT_VERS="${PKG_VERSION}"
export COMMIT_DATE="$(date -Idate -u)"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

for subdir in chunk concordance split_reference phase ligate
do
    pushd $subdir
    # Build the binaries
    make CXX="${CXX} -std=c++17" \
        DYN_LIBS="-lz -pthread -lbz2 -llzma -lcurl -lhts -ldeflate -lm" \
        CXXFLAG="${CXXFLAGS} ${PREFIX} -O3 -D__COMMIT_ID__='\"${COMMIT_VERS}\"' -D__COMMIT_DATE__='\"${COMMIT_DATE}\"' -Wno-ignored-attributes -O3 -mavx2 -mfma" \
        LDFLAG="${LDFLAGS}" \
	HTSSRC="${PREFIX}" \
        HTSLIB_INC="${PREFIX}/include" \
        HTSLIB_LIB="-lhts" \
        BOOST_INC="${PREFIX}/include"\
        BOOST_LIB_IO="-lboost_iostreams" \
        BOOST_LIB_PO="-lboost_program_options" \
        BOOST_LIB_SE="-lboost_serialization" \
        -j"${CPU_COUNT}" \
    ;
    # Install the binaries
    install -v -m 0755 "bin/GLIMPSE2_${subdir}" "${PREFIX}/bin"
    popd
done
