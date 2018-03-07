#!/bin/sh

#yum install glibc-static -y

# The CFLAGS are not available in the Makefile, so let us add it
sed -i -e  "s/\$(CXXFLAGS)/\$(CXXFLAGS) \$(CFLAGS)/g" src/Makefile

# There seem to be a missing library for the linkage (lrt)
#sed -i -e "s/-lpthread/-lpthread -lrt/g" Makefile

# The static boost_thread library cannot be found during the linkage. Let us
# comment the -static flag
sed -i -e "s/CXXFLAGS += -static/#CXXFLAGS += -static/g" Makefile


unamestr=`uname `
if [[ "$unamestr" == 'Linux' ]]; then

  # Tell the compiler where to find boost
  export CFLAGS=" -I${PREFIX}/include -L${PREFIX}/lib "
  # -L${CONDA_PREFIX}/lib -I${CONDA_PREFIX}"

  export CC=${PREFIX}/bin/gcc
  export CXX=${PREFIX}/bin/g++
else

  export BOOST_INCLUDE_DIR=${PREFIX}/include
  export BOOST_LIBRARY_DIR=${PREFIX}/lib
  export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
  export LDFLAGS="-L${BOOST_LIBRARY_DIR}"
 
  export CFLAGS=" -I${PREFIX}/include -L${PREFIX}/lib "

  export CC=clang
  export CXX=clang++

fi

make
make bin
cp bin/dsrc $PREFIX/bin

