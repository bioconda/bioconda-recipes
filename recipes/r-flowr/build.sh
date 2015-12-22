#!/bin/bash

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .

# Add more build steps here, if they are necessary.
BIN=$PREFIX/bin

FLOWR_BASE=$PREFIX/flowr
FLOWR_RUN=$PREFIX/flowr/runs
FLOWR_CONF=$PREFIX/flowr/conf
FLOWR_PIPE=$PREFIX/flowr/pipelines

$R -e "flowr::setup(bin='$BIN', flow_base_path='$FLOWR_BASE', flow_run_path='$FLOWR_RUN', flow_conf_path='$FLOWR_CONF', flow_pipe_path='$FLOWR_PIPE')"

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
