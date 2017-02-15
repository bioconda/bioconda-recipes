#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
CXXFLAGS="$CXXFLAGS";
LDFLAGS="$LDFLAGS";
if [ `uname` == Darwin ] ; then
    # boost-setup from https://github.com/conda/conda-recipes/blob/master/boost/build.sh
    echo "sorry.. cannot figure out how to build against the provided boost on osx.."
    exit -1;
else ## linux
    # add -fopenmp to compilation due to viennarna setup
    CXXFLAGS="-fopenmp"
fi

export CXXFLAGS=${CXXFLAGS}
export LDFLAGS=${LDFLAGS}

./configure --prefix=$PREFIX \
            --with-RNA=$PREFIX \
            --with-boost=$PREFIX \
            --disable-multithreading \
            ${extra_config_options} \
            
make && \
make tests && \
make install
