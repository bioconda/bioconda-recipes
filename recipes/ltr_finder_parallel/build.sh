#!/bin/sh
set -x -e

LTR_FINDER_PARALLEL_DIR=${PREFIX}/share/LTR_FINDER_parallel

mkdir -p ${PREFIX}/bin
mkdir -p ${LTR_FINDER_PARALLEL_DIR}
cp -r * ${LTR_FINDER_PARALLEL_DIR}

# LTR_FINDER_parallel creates the path to ltr_finder by using `which ltr_finder`
# `which ltr_finder` returns the path along with a newline character '\n'.
# To replace the newline character, LTR_FINDER_parallel matches regex 'ltr_finder\\n?'
# This regex logic fails in the case of this CONDA recipe because the path to 
# ltr_finder includes ltr_finder_parallel which is replaced as _parallel, resulting in
# an invalid path. I have changed the regex so that ltr_finder_parallel is not replaced.
sed -i.bak 's|\$ltr_finder=~s/ltr_finder\\n?//;|\$ltr_finder=~s/\\bltr_finder\\n?\$//m;|' \
    ${LTR_FINDER_PARALLEL_DIR}/LTR_FINDER_parallel

cat <<END >>${PREFIX}/bin/LTR_FINDER_parallel
#!/bin/bash
perl ${LTR_FINDER_PARALLEL_DIR}/LTR_FINDER_parallel \$@
END

chmod a+x ${PREFIX}/bin/LTR_FINDER_parallel
