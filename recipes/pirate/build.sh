#!/bin/sh
set -eu -o pipefail

mv bin test scripts "$PREFIX/"

# Include usefule PIRATE post-analysis tools
mv tools/convert_format/* ${PREFIX}/bin/
mv tools/subsetting/* ${PREFIX}/bin/
mv tools/treeWAS/* ${PREFIX}/bin/
chmod 755 ${PREFIX}/bin/*
