#!/bin/sh
set -x -e

# install dependencies
cpanm Getopt::Long::Subcommand

# copy the viewBS
mkdir -p ${PREFIX}/bin/
cp ViewBS ${PREFIX}/bin
chmod a+x ${PREFIX}/bin/ViewBS

# copy the lib
cp -r lib ${PREFIX}/bin
cp -r doc ${PREFIX}/bin
# modify the script
sed -i '1i #!/usr/bin/env Rscript' ${PREFIX}/bin/lib/scripts/mer_fig.R
chmod a+x ${PREFIX}/bin/lib/scripts/{brat2bismark.pl,bsseeker2bismark.pl,gff2tab.pl,mer_fig.R}
