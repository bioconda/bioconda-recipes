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
    MY_PATH_BACKUP=${PATH}         # backup path
    source activate python2
    PYTHON2_ENV=${CONDA_PREFIX}
    source deactivate
    export PATH=${MY_PATH_BACKUP}  # restore path

    ## Vienna rna expects python-config executable as python2-config,
    ## unfortunately some python 2.7 conda packages do not install it.
    ## Workaround: set symbolic link
    if [ ! -e $PYTHON2_ENV/bin/python2-config ]; then
      ln -sf $PYTHON2_ENV/bin/python-config $PYTHON2_ENV/bin/python2-config
    fi
    
    ## Add python2 env to search path (don't use activate, since we want
    ## to stay in the build environment)
    export PATH=${PYTHON2_ENV}/bin:$PATH
    
    PY2LIB=-L${PYTHON2_ENV}/lib

    ##
    ############################################################

fi

## Configure and make
./configure --prefix=$PREFIX \
            --without-perl \
            --with-kinwalker \
            --disable-lto \
            --without-doc \
            ${extra_config_options} \
            LIBS=${PY2LIB} \
            &&\
make -j${CPU_COUNT}

## Install
make install
