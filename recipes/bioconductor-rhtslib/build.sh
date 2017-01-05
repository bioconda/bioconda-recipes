
#!/bin/bash
/usr/bin/env
$R CMD config CC
$R CMD config CFLAGS
$R CMD config CPICFLAGS
$R CMD config LDFLAGS
$R CMD config CPPFLAGS
$R CMD config CPP
which gcc
trap "cat $SRC_DIR/src/htslib/config.log" ERR
# R refuses to build packages that mark themselves as
# "Priority: Recommended"
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
#
$R CMD INSTALL --build .
#
# # Add more build steps here, if they are necessary.
#
# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build
# process.
# 
