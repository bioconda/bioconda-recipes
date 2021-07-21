#!/bin/sh
set -x -e

# install dependencies
cpanm Getopt::Long::Subcommand
per_ver=$(perl -e '$ver=$^V; $ver=~s/v//; print $ver;')

# copy the viewBS
mkdir -p ${PREFIX}/bin
cp ViewBS ${PREFIX}/bin
chmod a+x ${PREFIX}/bin/ViewBS

# copy the scripts
cp lib/scripts/*.pl ${PREFIX}/bin
sed '1i #!/usr/bin/env Rscript' lib/scripts/mer_fig.R > ${PREFIX}/bin/mer_fig.R
chmod a+x ${PREFIX}/bin/{brat2bismark.pl,bsseeker2bismark.pl,gff2tab.pl,mer_fig.R}

# copy the depencies
mkdir -p ${PREFIX}/lib/site_perl/${per_ver}
cp -r doc ${PREFIX}/bin
cp -r lib/SubCmd ${PREFIX}/lib/site_perl/${per_ver}/
cp -r lib/Meth ${PREFIX}/lib/site_perl/${per_ver}/
