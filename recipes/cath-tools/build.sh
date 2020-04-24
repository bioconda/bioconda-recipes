#!/bin/bash
set -x -e

export CPATH="${PREFIX}/include"

#compile
DCMAKE=""
if [[ ${HOST} =~ .*darwin.* ]]; then
	MACOSX_DEPLOYMENT_TARGET=10.9
	DCMAKE+=" -DCMAKE_THREAD_LIBS_INIT=-lpthread -DCMAKE_HAVE_THREADS_LIBRARY=1"
	DCMAKE+=" -DCMAKE_USE_PTHREADS_INIT=1"
	export CXXFLAGS="${CXXFLAGS} -fvisibility=hidden -fvisibility-inlines-hidden"
fi

cmake -DGSL_LIBRARIES=${PREFIX}/include \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_INSTALL_PREFIX=$PREFIX \
			-DCMAKE_PREFIX_PATH=$PREFIX \
			-DCMAKE_CXX_COMPILER_RANLIB=${RANLIB} \
			${DCMAKE} \
			.

make -j${CPU_COUNT}

#list programs
CATH_PROGRAMS="cath-assign-domains cath-cluster cath-map-clusters cath-refine-align cath-resolve-hits cath-score-align cath-ssap cath-superpose"

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${CATH_PROGRAMS} ; do
	cp ${PROGRAM} ${PREFIX}/bin
done

#make everything executable in case in the bin
chmod +x ${PREFIX}/bin/*

# unitest
./build-test
