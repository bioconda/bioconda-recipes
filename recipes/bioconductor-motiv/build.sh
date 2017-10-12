#!/bin/bash

# Prev recipe had these custom lines
# export CFLAGS="$(gsl-config --cflags)"
# export LDFLAGS="$(gsl-config --libs)"
#
# # For whatever reason, it can't link to gsl correctly without this on OS X.
# export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
#
# export LD_LIBRARY_PATH=$PREFIX/lib

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
