#!/bin/sh
set -x -e

tetrimmer_DIR=${PREFIX}/share/tetrimmer

mkdir -p ${PREFIX}/bin
mkdir -p ${tetrimmer_DIR}
cp -r tetrimmer/* ${tetrimmer_DIR}

cat <<END >>${PREFIX}/bin/TEtrimmer
#!/bin/bash
python ${tetrimmer_DIR}/TEtrimmer.py \$@
END

chmod a+x ${PREFIX}/bin/TEtrimmer
