#!/bin/bash
set -ex

export CONDA_BLD_PATH=/tmp/conda-bld

mkdir -pv $CONDA_BLD_PATH
chmod 755 $CONDA_BLD_PATH

mkdir -p $PREFIX/bin

cp assignAlleleCodes_py3.6.py $PREFIX/bin/assignAlleleCodes
cp assignAlleleCodes_py3.6.py $PREFIX/bin/assignAlleleCodes_py3.6.py
chmod +x $PREFIX/bin/assignAlleleCodes

# ensure backward compatibility with a symlink
#pushd $PREFIX/bin
#ln -sv assignAllelecodes assignAlleleCodes_py3.6.py
#popd

echo "=== DONE WITH $0 ==="
