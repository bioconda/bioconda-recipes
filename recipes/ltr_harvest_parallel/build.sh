#!/bin/sh
set -x -e

mkdir -p ${PREFIX}/bin

cp -r LTR_HARVEST_parallel ${PREFIX}/bin
chmod a+x ${PREFIX}/bin/LTR_HARVEST_parallel
cp -r bin/cut.pl ${PREFIX}/bin
chmod a+x ${PREFIX}/bin/cut.pl

# change the path to cut.pl in LTR_HARVEST_parallel
sed -i 's|my \$cut = "\$script_path/bin/cut.pl"; #the program to cut sequence|my \$cut = "cut.pl"; #the program to cut sequence|' ${PREFIX}/bin/LTR_HARVEST_parallel
