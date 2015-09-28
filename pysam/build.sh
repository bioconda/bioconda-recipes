#!/bin/bash
# Remove gcc statements that do not work on older compilers for CentOS5
# support, from https://github.com/chapmanb/bcbio-conda/blob/master/pysam/build.sh
sed -i'' -e 's/"-Wno-error=declaration-after-statement",//g' setup.py
sed -i'' -e 's/"-Wno-error=declaration-after-statement"//g' setup.py
$PYTHON setup.py install
