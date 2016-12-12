#!/bin/bash

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .

# Add more build steps here, if they are necessary.
BIN=$PREFIX/bin


# create a link for the binary
ls -l .
cp ./inst/scripts/flowr $BIN/

# replicating some things also performed by the R's setup function
# env behaves differently, this may need some additional work
# to harmonize CRAN and conda installations.
#FLOWR_BASE=$HOME/flowr
#FLOWR_RUN=$HOME/flowr/runs
#FLOWR_CONF=$HOME/flowr/conf
#FLOWR_PIPE=$HOME/flowr/pipelines
# $R -e "flowr::setup(bin='$BIN', flow_base_path='$FLOWR_BASE', flow_run_path='$FLOWR_RUN', flow_conf_path='$FLOWR_CONF', flow_pipe_path='$FLOWR_PIPE')"

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
