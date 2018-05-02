#!/bin/bash

# R refuses to build packages that mark themselves as Priority: Recommended

unamestr=`uname`
if [ $unamestr == 'Linux' ];
then
    mv DESCRIPTION DESCRIPTION.old
    grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
    $R CMD INSTALL --build .
elif [ $unamestr == 'Darwin' ];
then
    export DYLD_LIBRARY_PATH=${PREFIX}/lib
    mv DESCRIPTION DESCRIPTION.old
    grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
    $R CMD INSTALL --build .
fi
