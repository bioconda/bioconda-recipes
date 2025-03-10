#!/bin/bash

# Go into the sub directory
pushd ASCAT

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

${R} CMD INSTALL --build . "${R_ARGS}"
