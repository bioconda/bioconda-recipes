#!/bin/bash

set -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

cd trans_proteomic_pipeline/src

echo "TPP_ROOT=${PREFIX}" > Makefile.config.incl
echo "TPP_WEB=${PREFIX}/web/" >> Makefile.config.incl
echo "CGI_USER_DIR=${PREFIX}/cgi-bin/" >> Makefile.config.incl
echo "HTMLDOC_BIN=" >> Makefile.config.incl
echo "LINK=shared" >> Makefile.config.incl
echo "LIBEXT=a" >> Makefile.config.incl

export C_INCLUDE_PATH=${INCLUDE_PATH}
export CPLUS_INCLUDE_PATH=${INCLUDE_PATH}

make all
make install
