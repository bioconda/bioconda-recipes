#!/bin/sh
set -x -e

LTR_HARVEST_PARALLEL_DIR=${PREFIX}/share/LTR_HARVEST_parallel

mkdir -p ${PREFIX}/bin
mkdir -p ${LTR_HARVEST_PARALLEL_DIR}
cp -r * ${LTR_HARVEST_PARALLEL_DIR} # copy everything (e.g. the bin dir containing cut.pl) to the directory

# create a wrapper script for LTR_HARVEST_parallel
cat <<END >>${PREFIX}/bin/LTR_HARVEST_parallel
#!/bin/bash
perl ${LTR_HARVEST_PARALLEL_DIR}/LTR_HARVEST_parallel \$@
END

# make the wrapper script executable
chmod a+x ${PREFIX}/bin/LTR_HARVEST_parallel