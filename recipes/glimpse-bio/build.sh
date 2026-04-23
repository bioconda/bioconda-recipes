#!/bin/bash

export COMMIT_VERS="${PKG_VERSION}"
export COMMIT_DATE="$(date -Idate -u)"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

OS=$(uname)
ARCH=$(uname -m)

if [[ "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ]]; then
	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h phase/src/models/

	sed -i.bak 's|#include <immintrin.h>|#include "sse2neon.h"|' phase/src/models/imputation_hmm.h
	sed -i.bak 's|#include <immintrin.h>|#include "sse2neon.h"|' phase/src/models/phasing_hmm.h
	rm -f phase/src/models/*.bak
	
	sed -i.bak -e "s/-mavx2 -mfma//" chunk/makefile
	sed -i.bak -e "s/-mavx2 -mfma//" concordance/makefile
	sed -i.bak -e "s/-mavx2 -mfma//" split_reference/makefile
	sed -i.bak -e "s/-mavx2 -mfma//" phase/makefile
	sed -i.bak -e "s/-mavx2 -mfma//" ligate/makefile
	export EXTRA_ARGS=""
else
	export EXTRA_ARGS="-mavx2 -mfma"
fi

for subdir in chunk concordance split_reference phase ligate

do
    pushd $subdir
    # Build the binaries
    make \
        -j"${CPU_COUNT}" \
        DYN_LIBS="-lz -pthread -lbz2 -llzma -lcurl -lhts -ldeflate -lm" \
        CXX="$CXX -std=c++17" \
        CXXFLAG="$CXXFLAGS ${PREFIX} -D__COMMIT_ID__='\"${COMMIT_VERS}\"' -D__COMMIT_DATE__='\"${COMMIT_DATE}\"' -Wno-ignored-attributes -O3 ${EXTRA_ARGS}" \
        LDFLAG="$LDFLAGS" \
        HTSLIB_INC="$PREFIX" \
        HTSLIB_LIB="-lhts" \
        BOOST_INC="/usr/include"\
        BOOST_LIB_IO="-lboost_iostreams" \
        BOOST_LIB_PO="-lboost_program_options" \
        BOOST_LIB_SE="-lboost_serialization" \
    ;
    # Install the binaries
    install -v -m 0755 "bin/GLIMPSE2_${subdir}" "${PREFIX}/bin"
    popd
done
