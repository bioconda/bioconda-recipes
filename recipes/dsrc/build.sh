#!/bin/sh

#yum install glibc-static -y


# The CFLAGS are not available in the Maefile, so let us add it
sed -i -e  "s/\$(CXXFLAGS)/\$(CXXFLAGS) \$(CFLAGS)/g" src/Makefile

# There seem to be a missing library for the linkage (lrt)
#sed -i -e "s/-lpthread/-lpthread -lrt/g" Makefile

# The static boost_thread library cannot be found during the linkage. Let us
# comment the -static flag
sed -i -e "s/CXXFLAGS += -static/#CXXFLAGS += -static/g" Makefile

# Tell the compiler where to find boost
export CFLAGS=" -I${PREFIX}/include -L${PREFIX}/lib "
# -L${CONDA_PREFIX}/lib -I${CONDA_PREFIX}"

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++


make
make bin
cp bin/dsrc $PREFIX/bin

