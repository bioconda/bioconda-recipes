#!/bin/bash

# prev version:
# export LD_LIBRARY_PATH=${PREFIX}/lib
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
