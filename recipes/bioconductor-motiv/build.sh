#!/bin/bash

export CFLAGS="$(gsl-config --cflags)"
export LDFLAGS="$(gsl-config --libs)"

if [ `uname` == Darwin ] ; then
  export LDFLAGS="-Wl,-rpath ${PREFIX}/lib $LDFLAGS"
fi
export LD_LIBRARY_PATH=$PREFIX/lib

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .