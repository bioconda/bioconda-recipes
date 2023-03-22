#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin

export CPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPP_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

sed -i.bak "369,377d" Makefile
make CFLAGS="$CFLAGS -D_GLIBCXX_PARALLEL -pthread -O3 -Wall -std=gnu99" CXXFLAGS="$CXXFLAGS -D_GLIBCXX_PARALLEL -pthread -O3 -Wall -std=c++11" LDFLAGS="$LDFLAGS -pthread -lm -fopenmp -lz -lstdc++"

OSTYPE=`uname`
MACHINETYPE=`uname -m`

if [ $MACHINETYPE = x86_64 ]; then
        MACHINETYPE="amd64"
fi

if [ ${MACHINETYPE} = "Power Macintosh" ]; then
        MACHINETYPE="ppc"
fi

if [ ${OSTYPE} = "SunOS" ]; then
        MACHINETYPE=`uname -p`
        if [ ${MACHINETYPE} = "sparc" ]; then
                if [ ${/usr/bin/isainfo -b} = "64" ]; then
                        MACHINETYPE="sparc64"
                else
                        MACHINETYPE="sparc332"
                fi
        fi
fi

cp ${OSTYPE}-${MACHINETYPE}/bin/Fec ${PREFIX}/bin
cp script/parse_sam.py ${PREFIX}/bin
chmod +x ${PREFIX}/bin/parse_sam.py
