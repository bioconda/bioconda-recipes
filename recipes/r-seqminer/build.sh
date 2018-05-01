#!/bin/bash

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .

if [ $unamestr == 'Darwin' ];
then
    export DYLD_LIBRARY_PATH=$PREFIX/lib
