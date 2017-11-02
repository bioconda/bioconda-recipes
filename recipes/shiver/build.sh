#!/bin/bash

set -euf -o pipefail

mkdir -p $PREFIX/bin
cp ${SRC_DIR}/config.sh $PREFIX/bin/shiver_config.sh
cp ${SRC_DIR}/shiver_align_contigs.sh $PREFIX/bin
cp ${SRC_DIR}/shiver_full_auto.sh $PREFIX/bin
cp ${SRC_DIR}/shiver_funcs.sh $PREFIX/bin
cp ${SRC_DIR}/shiver_init.sh $PREFIX/bin
cp ${SRC_DIR}/shiver_map_reads.sh $PREFIX/bin
cp ${SRC_DIR}/shiver_reprocess_bam.sh $PREFIX/bin

if [ $PY3K == "True" ] || [ $PY3K == "1" ]
then
    2to3 --write --nobackups tools/
else
		# One of shiver's dependencies, fastaq, requires Python 3.
		# If this is a Python 2 installation, we install a script which,
		# the first time it is run, installs Python 3 and pyfastaq in a separate
		# environment, and thereafter invokes pyfastaq after temporarily activating
		# that environment.
    cp ${SRC_DIR}/shiver_fastaq $PREFIX/bin
    chmod u+x $PREFIX/bin/shiver_fastaq
fi

cp -r ${SRC_DIR}/tools $PREFIX/bin/shiver_tools
