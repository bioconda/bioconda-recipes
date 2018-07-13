#!/bin/bash

cd seqcluster/align
if [ "$(uname)" == "Darwin"  ]; then
    gcc -c -lpython2.7 -ldl -framework CoreFoundation -u _PyMac_Error  -I$PREFIX/include/python2.7 pyMatch.c pyMatch_wrap.c
    gcc -bundle `python-config --ldflags` pyMatch_wrap.o pyMatch.o -o _pyMatch.so
fi
cd -

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
