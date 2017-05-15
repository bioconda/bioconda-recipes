
#!/bin/bash

if [ `uname` == Darwin ]; then
        export MACOSX_DEPLOYMENT_TARGET=10.9
fi
# R refuses to build packages that mark themselves as
# "Priority: Recommended"
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
#
export CXXFLAGS="${CXXFLAGS} -std=c++11"
$R CMD INSTALL --build .
#
# # Add more build steps here, if they are necessary.
#
# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build
# process.
# 
