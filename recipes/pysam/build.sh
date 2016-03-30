#!/bin/bash
# Remove gcc statements that do not work on older compilers for CentOS5
# support, from https://github.com/chapmanb/bcbio-conda/blob/master/pysam/build.sh
sed -i'' -e 's/"-Wno-error=declaration-after-statement",//g' setup.py
sed -i'' -e 's/"-Wno-error=declaration-after-statement"//g' setup.py
# linking htslib, see:
# http://pysam.readthedocs.org/en/latest/installation.html#external
# https://github.com/pysam-developers/pysam/blob/v0.9.0/setup.py#L79
#export HTSLIB_LIBRARY_DIR=$PREFIX/lib
#export HTSLIB_INCLUDE_DIR=$PREFIX/include
sed -i'' -e 's/HTSLIB_MODE = \"shared\"/HTSLIB_MODE = \"separate\"/g' setup.py
$PYTHON setup.py install
