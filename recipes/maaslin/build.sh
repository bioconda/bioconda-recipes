#!/bin/bash


# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .


# copy supplementary scripts
chmod +x exec/*.py
cp exec/*.py ${PREFIX}/bin
