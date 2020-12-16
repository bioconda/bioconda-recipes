#!/bin/bash

# pthreads
CXX=mpicxx ./install.sh
./checker.sh
#ln -s "$(pwd)pargenes/pargenes.py" ${PREFIX}/bin/pargenes.py
#ln -s "$(pwd)pargenes/pargenes-hpc.py" ${PREFIX}/bin/pargenes-hpc.py
#ln -s "$(pwd)pargenes/pargenes-hpc-debug.py" ${PREFIX}/bin/pargenes-hpc-debug.py

dest=${PREFIX}/bin
mkdir -p ${dest}

# copy over all relevant files for the package
for file in raxml-ng modeltest-ng mpi-scheduler; do
  find . -type f -name ${file} -print -exec cp --parents '{}' ${dest} \;
done

for patt in ".*/pargenes/.*\.py" ".*\.so" ".*\.jar" ".*\.dylib"; do
  find . -type f -regextype posix-egrep -regex "${patt}" -print -exec cp --parents '{}' ${dest} \;
done

cd ${dest}
ln -s "pargenes/pargenes.py" "pargenes.py"
ln -s "pargenes/pargenes-hpc.py" "pargenes-hpc.py"
ln -s "pargenes/pargenes-hpc-debug.py" "pargenes-hpc-debug.py"
