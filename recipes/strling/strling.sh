#bin/bash
echo $CONDA_PREFIX
if [ -z $CONDA_PREFIX ]; then
  CONDA_PREFIX=$(dirname $(dirname "$(readlink -f "$0")"))
fi
LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH $CONDA_PREFIX/share/strling $@
