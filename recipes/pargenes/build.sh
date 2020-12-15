#!/bin/bash

# pthreads
./install.sh
./checker.sh
install pargenes/pargenes.py ${PREFIX}/bin
install pargenes/pargenes-hpc.py ${PREFIX}/bin
install pargenes/pargenes-hpc-debug.py ${PREFIX}/bin

