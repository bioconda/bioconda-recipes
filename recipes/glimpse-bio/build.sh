#!/bin/bash

export COMMIT_VERS="${PKG_VERSION}"
export COMMIT_DATE="$(date -Idate -u)"

for subdir in chunk concordance split_reference phase ligate

do
    pushd $subdir
    # Build the binaries
    make \
        -j 4 \
        DYN_LIBS="-lz -lpthread -lbz2 -llzma -lcurl -lhts -ldeflate -lm" \
        CXX="$CXX -std=c++17" \
        CXXFLAG="$CXXFLAGS ${PREFIX} -D__COMMIT_ID__='\"${COMMIT_VERS}\"' -D__COMMIT_DATE__='\"${COMMIT_DATE}\"' -Wno-ignored-attributes -O3 -mavx2 -mfma" \
        LDFLAG="$LDFLAGS" \
        HTSLIB_INC="$PREFIX" \
        HTSLIB_LIB="-lhts" \
        BOOST_INC="/usr/include"\
        BOOST_LIB_IO="-lboost_iostreams" \
        BOOST_LIB_PO="-lboost_program_options" \
        BOOST_LIB_SE="-lboost_serialization" \
    ;
    # Install the binaries
    install "bin/GLIMPSE2_${subdir}" "${PREFIX}/bin"
    popd
done
