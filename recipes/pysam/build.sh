#!/bin/bash
# Remove gcc statements that do not work on older compilers for CentOS5
# support, from https://github.com/chapmanb/bcbio-conda/blob/master/pysam/build.sh
sed -i'' -e 's/"-Wno-error=declaration-after-statement",//g' setup.py
sed -i'' -e 's/"-Wno-error=declaration-after-statement"//g' setup.py
#export HTSLIB_LIBRARY_DIR=$PREFIX/lib:$HTSLIB_LIBRARY_DIR
#export HTSLIB_INCLUDE_DIR=$PREFIX/include:$HTSLIB_INCLUDE_DIR
sed -i 's/HTSLIB_MODE = \"shared\"/HTSLIB_MODE = \"separate\"/g' setup.py
$PYTHON setup.py install
