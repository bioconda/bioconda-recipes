#!/bin/bash

# Make m4 accessible to bison
# https://github.com/conda-forge/bison-feedstock/issues/7#issuecomment-431602144
export M4=m4
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

# build
CXX=mpicxx ./install.sh

dest=${PREFIX}/bin
mkdir -p ${dest}

echo "Pargenes installer: copying the three main executables"
# copy over all relevant files for the package


dependencies="raxml-ng" "modeltest-ng" "mpi-scheduler" "astral.jar"
if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  dependencies+=( "raxml-ng-mpi.so" "modeltest-ng-mpi/so" )
fi

for file in $dependencies do
  find . -type f -name ${file} -print -exec cp --parents '{}' ${dest} \;
done

echo "Pargenes installer: before cd ${dest}"
cd ${dest}
echo "Pargenes installer: Before ln"
ln -s pargenes/pargenes.py pargenes.py
ln -s pargenes/pargenes-hpc.py pargenes-hpc.py
ln -s pargenes/pargenes-hpc-debug.py pargenes-hpc-debug.py
