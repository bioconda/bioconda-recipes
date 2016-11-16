#!/bin/bash

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

# On OS X, the only way to build packages currently is by having
# DYLD_FALLBACK_LIBRARY_PATH set. We do not use DYLD_LIBRARY_PATH because that
# screws up some of the system libraries that have older versions of libjpeg
# than the one in Anaconda. DYLD_FALLBACK_LIBRARY_PATH will only come
# into play if it cannot find the library via normal means. The default comes
# from 'man dyld'.
export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib:$(HOME)/lib:/usr/local/lib:/lib:/usr/lib

$R CMD INSTALL --build .

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
