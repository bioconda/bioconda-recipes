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
#-lboost_thread
DCMAKE=""
declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
	MACOSX_DEPLOYMENT_TARGET=10.9
	DCMAKE+=" -DCMAKE_THREAD_LIBS_INIT=-lpthread -DCMAKE_HAVE_THREADS_LIBRARY=1"
	DCMAKE+=" -DCMAKE_USE_PTHREADS_INIT=1 -DCMAKE_DL_LIBS=-ldl"
	DCMAKE+="	-DCMAKE_MACOSX_RPATH=ON "
	RPATH='@loader_path/../lib'
	export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
	#export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:${PREFIX}/lib"
	#DCMAKE=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
  #export CXXFLAGS="${CXXFLAGS} -isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
	LDFLAGS+=" -lz -lm"
	export CXXFLAGS="${CXXFLAGS} -fvisibility=hidden -fvisibility-inlines-hidden"
fi

#LDFLAGS+=' -Wl,-rpath,${RPATH}'
LDFLAGS+=' -Wl,-rpath,./'

# use, i.e. don't skip the full RPATH for the build tree
DCMAKE+=" -DCMAKE_SKIP_BUILD_RPATH=FALSE"

# when building, don't use the install RPATH already
# (but later on when installing)
DCMAKE+=" -DCMAKE_BUILD_WITH_INSTALL_RPATH=FALSE"

# the RPATH to be used when installing
#-DCMAKE_INSTALL_RPATH="" \

# don't add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
DCMAKE+=" -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE"

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

make -j${CPU_COUNT}  #CXX=${CXX} CXXFLAGS="${CXXFLAGS}"

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${CATH_PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
	chmod a+x ${PREFIX}/bin/${PROGRAM}
done

# save cath-tools folder in share
mkdir -p ${PREFIX}/share/cath-tools
cp -r * ${PREFIX}/share/cath-tools

#make everything executable in case in the bin
chmod +x $PREFIX/bin/*
