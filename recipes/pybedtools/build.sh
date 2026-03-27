#!/bin/bash

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
