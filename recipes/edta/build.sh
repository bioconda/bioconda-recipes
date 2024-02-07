#!/bin/sh
set -x -e

EDTA_DIR=${PREFIX}/share/EDTA
EDTA_OTHER_PROGRAMS="EDTA_raw.pl EDTA_processI.pl lib-test.pl"

mkdir -p ${PREFIX}/bin
mkdir -p ${EDTA_DIR}
cp -r * ${EDTA_DIR}

cat <<END >>${PREFIX}/bin/EDTA.pl
#!/bin/bash
NAME=\$(basename \$0)
perl ${EDTA_DIR}/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/EDTA.pl
for name in ${EDTA_OTHER_PROGRAMS} ; do
  ln -sf ${PREFIX}/bin/EDTA.pl ${PREFIX}/bin/$(basename $name)
done

ln -sf ${EDTA_DIR}/development/EDTA_processI.pl ${PREFIX}/bin/

LTR_FINDER_PARALLEL_DIR=${EDTA_DIR}/bin/LTR_FINDER_parallel

cat <<END >>${PREFIX}/bin/LTR_FINDER_parallel
#!/bin/bash
perl ${LTR_FINDER_PARALLEL_DIR}/LTR_FINDER_parallel \$@
END

chmod a+x ${PREFIX}/bin/LTR_FINDER_parallel