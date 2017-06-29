#!/bin/bash

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

# be sure to link the tbb libraries correctly
sed -i.bak 's/LIB_LINK_FLAGS = -dynamiclib/LIB_LINK_FLAGS = -dynamiclib -Wl -headerpad_max_install_names/' src/tbb/build/macos.clang.inc

$R CMD INSTALL --build  .


# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
