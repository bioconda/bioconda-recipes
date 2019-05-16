#!/bin/bash
PYTHON_INCLUDE_DIR=$($PYTHON -c 'import distutils.sysconfig, sys; sys.stdout.write(distutils.sysconfig.get_python_inc())')
export CFLAGS="-fpic -Wall -O3 -std=c++11 -I$PYTHON_INCLUDE_DIR -I${PREFIX}/include -L${PREFIX}/lib"
export LFLAGS="-fpic -shared -L${PREFIX}/lib -lboost_regex"
sed -i.bak -e 's/^CFLAGS =.*//g' makefile
sed -i.bak -e 's/^LFLAGS =.*//g' makefile
make
mv tagcorpus ${PREFIX}/bin/
