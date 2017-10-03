#!/bin/bash

if [ `uname` == Darwin ]; then
        export MACOSX_DEPLOYMENT_TARGET=10.9
fi
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
#
export CXXFLAGS="${CXXFLAGS} -std=c++11"
$R CMD INSTALL --build .