#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
if [ `uname` == Darwin ] ; then
    extra_config_options="--disable-openmp 
                          --enable-universal-binary
                          --without-python3
                          LDFLAGS=-Wl,-headerpad_max_install_names"
else ## linux
    extra_config_options="--with-python3 --with-python"

    ############################################################
    ## Vienna requires Python 2 and 3 at run time to generate Swig
    ## bindings for both. Since conda does not allow installation of both
    ## python versions in the same environment, we perform this
    ## workaround: install Python 2 in a different environment and set the
    ## path accordingly.
    ##
    
    ## install python 2.7 in separate environment
    conda create -y -n python2 'python<3'
    
    ## get path to python2 environment
    source activate python2
    PYTHON2_ENV=${CONDA_PREFIX}
    source deactivate
    
    ## Vienna rna expects python-config executable as python2-config,
    ## unfortunately the python 2.7 conda package does not install it.
    ## Workaround: set symbolic link
    ln -sf $PYTHON2_ENV/bin/python-config $PYTHON2_ENV/bin/python2-config
    
    ## Add python2 env to search path (don't use activate, since we want
    ## to stay in the build environment)
    export PATH=$PYTHON2_ENV/bin:$PATH
    
    ##
    ############################################################

fi

## Configure and make
./configure --prefix=$PREFIX \
            --without-perl \
            --with-kinwalker \
            --disable-lto \
            --without-doc \
            ${extra_config_options} &&\
make -j${CPU_COUNT}

## Install
make install
