#!/bin/bash
export DISABLE_AUTOBREW=1

mv DESCRIPTION DESCRIPTION.old
grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION
${R} CMD INSTALL --build . ${R_ARGS}

# https://docs.conda.io/projects/conda-build
# for a list of environment variables that are set during the build process.