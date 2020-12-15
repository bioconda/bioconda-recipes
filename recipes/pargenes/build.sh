#!/bin/bash

# pthreads
CXX=mpicxx ./install.sh
./checker.sh
ln -s "$(pwd)pargenes/pargenes.py" ${PREFIX}/bin/pargenes.py
ln -s "$(pwd)pargenes/pargenes-hpc.py" ${PREFIX}/bin/pargenes-hpc.py
ln -s "$(pwd)pargenes/pargenes-hpc-debug.py" ${PREFIX}/bin/pargenes-hpc-debug.py

