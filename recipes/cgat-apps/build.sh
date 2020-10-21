#!/bin/bash

# export compiler flags
#export CFLAGS=${CFLAGS}" -I${PREFIX}/include -L${PREFIX}/lib"
#export CPPFLAGS=${CPPFLAGS}" -I${PREFIX}/include -L${PREFIX}/lib"
export LDFLAGS=${LDFLAGS}" -I${PREFIX}/include -L${PREFIX}/lib"
export CPATH=${CPATH}" -I${PREFIX}/include -L${PREFIX}/lib"
export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${PREFIX}/include
export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH=${LIBRARY_PATH}:${PREFIX}/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PREFIX}/lib:${PREFIX}/lib/R/lib

# linking htslib, see:
# http://pysam.readthedocs.org/en/latest/installation.html#external
# https://github.com/pysam-developers/pysam/blob/v0.9.0/setup.py#L79
#export CFLAGS="-I$PREFIX/include -DHAVE_LIBDEFLATE"
#export CPPFLAGS="-I$PREFIX/include -DHAVE_LIBDEFLATE"
#export LDFLAGS="-L$PREFIX/lib"

#export HTSLIB_LIBRARY_DIR=$PREFIX/lib
#export HTSLIB_INCLUDE_DIR=$PREFIX/include

# remove install_requires (no longer required with conda package)
sed -i'' -e '/REPO_REQUIREMENT/,/pass/d' setup.py
sed -i'' -e '/# dependencies/,/dependency_links=dependency_links,/d' setup.py

# https://bioconda.github.io/linting.html#setup-py-install-args
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

