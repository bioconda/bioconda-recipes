#!/bin/sh
set -x -e

LTR_HARVEST_PARALLEL_DIR=${PREFIX}/share/LTR_HARVEST_parallel

mkdir -p ${PREFIX}/bin
mkdir -p ${LTR_HARVEST_PARALLEL_DIR}
cp -r bin/LTR_HARVEST_parallel/* ${LTR_HARVEST_PARALLEL_DIR}

cat <<END >>${PREFIX}/bin/LTR_HARVEST_parallel
#!/bin/bash
perl ${LTR_HARVEST_PARALLEL_DIR}/LTR_HARVEST_parallel \$@
END

chmod a+x ${PREFIX}/bin/LTR_HARVEST_parallel
