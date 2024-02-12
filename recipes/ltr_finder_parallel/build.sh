#!/bin/sh
set -x -e

LTR_FINDER_PARALLEL_DIR=${PREFIX}/share/LTR_FINDER_parallel

mkdir -p ${PREFIX}/bin
mkdir -p ${LTR_FINDER_PARALLEL_DIR}
cp -r * ${LTR_FINDER_PARALLEL_DIR}

cat <<END >>${PREFIX}/bin/LTR_FINDER_parallel
#!/bin/bash
perl ${LTR_FINDER_PARALLEL_DIR}/LTR_FINDER_parallel \$@
END

chmod a+x ${PREFIX}/bin/LTR_FINDER_parallel
