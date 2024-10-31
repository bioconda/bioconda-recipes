#!/bin/bash

export COMMIT_VERS="${PKG_VERSION}"
export COMMIT_DATE="$(date -Idate -u)"

make \
    -j 4 \
    DYN_LIBS="-lz -lpthread -lbz2 -lblas" \
    CXX="$CXX -std=c++17" \
    CXXFLAG="$CXXFLAGS ${PREFIX} -D__COMMIT_ID__='\"${COMMIT_VERS}\"' -D__COMMIT_DATE__='\"${COMMIT_DATE}\"' \
    LDFLAG="$LDFLAGS" \
    HTSLIB_INC="$PREFIX" \
    HTSLIB_LIB="-lhts" \
    BOOST_INC="/usr/include"\
    BOOST_LIB_IO="-lboost_iostreams" \
    BOOST_LIB_PO="-lboost_program_options" \
    BOOST_LIB_SE="-lboost_serialization" \
    ;
install "bin/eagle" "eagle/bin"
popd
