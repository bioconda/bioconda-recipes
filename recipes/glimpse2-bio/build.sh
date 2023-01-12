#!/bin/bash

for subdir in chunk concordance ligate phase split_reference
do
    pushd $subdir
    # Build the binaries
    make \
        -j 4 \
        CXX="$CXX -std=c++17" \
        DYN_LIBS="-lz -lpthread -lbz2 -llzma -lcurl -lhts -ldeflate" \
        COMMIT_VERS="3bed6d9" \
        COMMIT_DATE="2022-12-07" \
        HTSLIB_INC="$PREFIX" \
        HTSLIB_LIB="-lhts" \
        BOOST_LIB_IO="-lboost_iostreams" \
        BOOST_LIB_PO="-lboost_program_options" \
	BOOST_LIB_SE="-lboost_serialization" \
    ;
    # Install the binaries
    install "bin/GLIMPSE2_${subdir}" "${PREFIX}/bin"
    popd
done
