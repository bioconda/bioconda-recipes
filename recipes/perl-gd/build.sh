#!/bin/bash

# ensure script fail on command fail
set -e -o pipefail

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL \
    	-options "JPEG,PNG,FT" \
    	-lib_jpeg_path $PREFIX \
    	-lib_ft_path2 $PREFIX \
    	-lib_png_path $PREFIX \
    	>&1;
    ./Build 2>&1;
    ./Build test 2>&1;
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
