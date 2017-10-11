#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

# prev version:
# # Ensure C++11 compatibility for macOS
# if [ `uname` == "Darwin" ]; then
# 	export MACOSX_DEPLOYMENT_TARGET=10.9
# fi
$R CMD INSTALL --build .
