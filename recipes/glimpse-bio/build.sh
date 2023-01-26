#!/bin/bash

COMMIT_VERS=git rev-parse --short HEAD
COMMIT_DATE=git log -1 --format=%cd --date=short
__COMMIT_ID__="$COMMIT_VERS"
__COMMIT_DATE__="$COMMIT_DATE"

for subdir in chunk split_reference phase ligate

do
    pushd $subdir
    # Build the binaries
    make \
        -j 4 \
        DYN_LIBS="-lz -lpthread -lbz2 -llzma -lcurl -lhts -ldeflate -lm" \
        CXX="$CXX -std=c++11" \
        CXXFLAG="$CXXFLAGS ${PREFIX} $COMMIT_VERS $COMMIT_DATE" \
        LDFLAG="$LDFLAGS" \
        HTSLIB_INC="$PREFIX" \
        HTSLIB_LIB="-lhts" \
        BOOST_INC="/usr/include"\
        BOOST_LIB_IO="-lboost_iostreams" \
        BOOST_LIB_PO="-lboost_program_options" \
        BOOST_LIB_SE="-lboost_serialization" \
    ;
    # Install the binaries
    install "bin/GLIMPSE_${subdir}" "${PREFIX}/bin"
    popd
done
