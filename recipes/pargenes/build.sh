#!/bin/bash

# Make m4 accessible to bison
# https://github.com/conda-forge/bison-feedstock/issues/7#issuecomment-431602144
export M4=m4
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

# build
export OMPI_MCA_rmaps_base_oversubscribe=1 
export OMPI_ALLOW_RUN_AS_ROOT=1 
export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 

echo "Bioconda Pargenes installer: running install.sh"
if [[ "$OSTYPE" == "darwin"* ]]; then
  ./install.sh 1
else
  CXX=mpicxx ./install.sh
fi

dest=${PREFIX}/bin/
mkdir -p ${dest}

cp -r pargenes/* $dest

echo "Bioconda Pargenes installer: running python tests/run_tests.py"
python tests/run_tests.py --run-as-binary --report

