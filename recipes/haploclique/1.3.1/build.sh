#!/use/bin/env sh

# HACK GCC 4.8.5 ships with a broken std::regex (it's only fixed with GCC 4.9.0)
if [[ `c++ -dumpversion` == 4.8.* ]]; then
    echo 'GCC version 4.8.x detected, forcing switch of regex engine from C++11 to Boost'
    USE_BOOST_REGEX='-DUSE_BOOST_REGEX=1'
fi

mkdir -p build && cd build

export C_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}"   \
      -DBOOST_ROOT="${PREFIX}" -DBoost_NO_SYSTEM_PATHS=ON "${USE_BOOST_REGEX}"    \
      -DCMAKE_SKIP_BUILD_RPATH=FALSE -DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE -DCMAKE_INSTALL_RPATH="${PREFIX}/lib64:${PREFIX}/lib:${PREFIX}/lib/bamtools" -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE    \
      ..   \
    && make \
    && make install

## unit tests
# NOTE disabling unit tests to shave off a few seconds of Travis' runtime
#export LIBRARY_PATH="${PREFIX}/lib64:${PREFIX}/lib:${PREFIX}/lib/bamtools:${LIBRARY_PATH:+:${LIBRARY_PATH}}" 
#make check 
