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
    MY_PYTHON2_ENV_NAME=viennarna_builder_python2
    
    ## install python 2.7 in separate environment
    #
    
    # if env $MY_PYTHON2_ENV_NAME exists, remove it
    if conda env list | grep -w "$MY_PYTHON2_ENV_NAME" > /dev/null ; then
        conda env remove -y -n "$MY_PYTHON2_ENV_NAME"
    fi

    # create new env $MY_PYTHON2_ENV_NAME with python<3
    conda create -y -n $MY_PYTHON2_ENV_NAME 'python<3'
    
    ## get path to $MY_PYTHON2_ENV_NAME environment
    MY_PATH_BACKUP=${PATH}         # backup path
    source activate $MY_PYTHON2_ENV_NAME
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


## cleanup env $MY_PYTHON2_ENV_NAME
if [ "$MY_PYTHON2_ENV_NAME" != "" ] ; then
   if conda env list | grep -w "$MY_PYTHON2_ENV_NAME" > /dev/null ; then
       conda env remove -y -n "$MY_PYTHON2_ENV_NAME"
   fi
fi
