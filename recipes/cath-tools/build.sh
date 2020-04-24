#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="-I$PREFIX/include"
export CPATH="${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I${PREFIX}/include"


#list programs
CATH_PROGRAMS="build-test cath-assign-domains cath-cluster cath-map-clusters cath-refine-align cath-resolve-hits cath-score-align cath-ssap cath-superpose"

#compile
DCMAKE=""
if [[ ${HOST} =~ .*darwin.* ]]; then
	MACOSX_DEPLOYMENT_TARGET=10.9
	DCMAKE+=" -DCMAKE_THREAD_LIBS_INIT=-lpthread -DCMAKE_HAVE_THREADS_LIBRARY=1"
	DCMAKE+=" -DCMAKE_USE_PTHREADS_INIT=1"
	export CXXFLAGS="${CXXFLAGS} -fvisibility=hidden -fvisibility-inlines-hidden"
fi

cmake -DGSL_LIBRARIES=${PREFIX}/include \
			-DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON \
			-DCMAKE_INSTALL_RPATH="" \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_INSTALL_PREFIX=$PREFIX \
			-DBoost_DEBUG=ON \
			-DCMAKE_PREFIX_PATH=$PREFIX \
			-DCMAKE_CXX_COMPILER_RANLIB=${RANLIB} \
			${DCMAKE} \
			.

make -j${CPU_COUNT}

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${CATH_PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
	chmod a+x ${PREFIX}/bin/${PROGRAM}
done

#make everything executable in case in the bin
chmod +x ${PREFIX}/bin/*
