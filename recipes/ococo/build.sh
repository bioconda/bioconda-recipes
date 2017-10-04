#!/bin/bash


##strictly use anaconda build environment
#CXX=${PREFIX}/bin/g++

#to fix problems with zlib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

(
	cd ext
	rm -fr htslib
	git clone git://github.com/samtools/htslib
        cd htslib && git checkout tags/1.3.2
)

#echo "g++"
#g++ -v || true
#echo "c++"
#c++ -v || true
#echo "CXX"
#$CXX -v || true

make VERBOSE=1
mkdir -p ${PREFIX}/bin
cp ococo ${PREFIX}/bin
if [ -e ${PREFIX}/share/man/man1 ]; then
    cp ococo.1 ${PREFIX}/share/man/man1
fi

