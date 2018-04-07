#!/bin/sh

# The static boost_thread library cannot be found during the linkage. Let us
# comment the -static flag
sed -i -e "s/CXXFLAGS += -static/#CXXFLAGS += -static/g" Makefile

# Append to CXXFLAGS instead of overiding it
sed -i -e "s/CXXFLAGS =/CXXFLAGS +=/g" Makefile

# Tell the compiler where to find boost
export CXXFLAGS=" -I${PREFIX}/include -L${PREFIX}/lib "

#CXX=${PREFIX}/bin/g++

if [ "$(uname)" == "Darwin" ]; then
    make -f Makefile.osx bin #CXX=$CXX
else
    make bin #CXX=$CXX
fi

cp bin/dsrc $PREFIX/bin
