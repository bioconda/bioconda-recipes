#!/bin/sh

#cmake -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=$PREFIX .
#make clean

if [ "$(uname)" == "Darwin" ]; then
    # c++11 compatibility

    export CXXFLAGS=' -stdlib=libc++'
    export CXX_FLAGS=' -stdlib=libc++'
    export CMAKE_CXX_FLAGS=' -stdlib=libc++'
    export LDFLAGS=' -stdlib=libc++'
    export LD_FLAGS=' -stdlib=libc++'
    export CMAKE_LDFLAGS=' -stdlib=libc++'
fi

cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON .


make VERBOSE=1
make install

cd scripts/energy-estimation-utility

# 'setup_requires' and 'install_requires' break setuptools stuff
sed -i.bak -E "s/setup_requires.+\],//" setup.py
sed -i.bak -E "s/install_requires.+\],//" setup.py

$PYTHON setup.py install
