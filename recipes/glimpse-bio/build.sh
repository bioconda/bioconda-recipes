#!/bin/bash


for subdir in chunk concordance ligate phase sample snparray
do
    pushd $subdir
    # Build the binaries
    make \
        -j 4 \
        DYN_LIBS="-lz -lpthread -lbz2 -llzma -lcurl -lhts -ldeflate" \
        CXX="$CXX -std=c++11" \
        CXXFLAG="$CXXFLAGS ${PREFIX}/lib" \
        LDFLAG="$LDFLAGS" \
        HTSLIB_INC=${PREFIX}/lib \
        HTSLIB_LIB=${PREFIX}/lib/libhts.a \
        BOOST_LIB_IO=${PREFIX}/lib/libboost_iostreams.a \
        BOOST_LIB_PO=${PREFIX}/lib/libboost_program_options.a \
    ;
    # Install the binaries
    install bin/GLIMPSE_${subdir}
    popd
done
