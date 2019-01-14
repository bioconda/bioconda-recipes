#!/usr/bin/env bash
set -e
#export JAVA_HOME=$(readlink -f `type -p javac` | sed "s:/bin/javac::");

# Typically $GXX is set by activate.d in conda
# based on our compiler('cxx') dependency
# https://conda.io/docs/user-guide/tasks/build-packages/compiler-tools.html
CXX=${GXX:-g++}
CXXCPP="${CXX} -E"
export CXX
export CXXCPP


export INCLUDE_PATH="${PREFIX}/include/:${PREFIX}/include/bamtools/"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR="${PREFIX}/include"
export BOOST_LIBRARY_DIR="${PREFIX}/lib"
export LIBS='-lboost_regex -lboost_system -lboost_filesystem -lboost_program_options -lboost_filesystem -lboost_timer'
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include

export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR} ${LIBS}"

# Run the COMPSs install script
./install

# TODO: Set up equivalent of /etc/profile.d/compss.sh
# in ./etc/conda/activate.d
