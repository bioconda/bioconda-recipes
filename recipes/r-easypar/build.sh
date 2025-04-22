#!/bin/bash
export DISABLE_AUTOBREW=1
# shellcheck disable=SC2086
${R} CMD INSTALL --build . ${R_ARGS}

# Add more build steps here, if they are necessary.

# See
# https://docs.conda.io/projects/conda-build
# for a list of environment variables that are set during the build process.
