#!/bin/bash


for subdir in chunk concordance ligate phase sample snparray
do
    pushd $subdir
    # Build the binaries
    make \
        -j 4 \
        DYN_LIBS="-lz -lpthread -lbz2 -llzma -lcurl -lhts -ldeflate" \
        CXX="$CXX -std=c++11" \
        CXXFLAG="$CXXFLAGS ${PREFIX}" \
        LDFLAG="$LDFLAGS" \
        HTSLIB_INC="$PREFIX" \
        HTSLIB_LIB="-lhts" \
        BOOST_LIB_IO="-lboost_iostreams" \
        BOOST_LIB_PO="-lboost_program_options" \
    ;
    # Install the binaries
    install "bin/GLIMPSE_${subdir}" "${PREFIX}/bin"
    popd
done
