#!/bin/bash

# From setup.py: User must check GCC, if >= 4.6, use -Ofast, otherwise -O3.
GCCVERSION=$( gcc -dumpversion )
GCCVERSION_MAJOR=$(echo $GCCVERSION | awk 'BEGIN {FS="."}; {print $1}')
GCCVERSION_MINOR=$(echo $GCCVERSION | awk 'BEGIN {FS="."}; {print $2}')

if [ $GCCVERSION_MAJOR -le 4 ]; then
    if [ $GCCVERSION_MINOR -le 5 ]; then
	sed -i'' -e 's/"-Ofast"/"-O3"/g' setup.py
    fi
fi

$PYTHON setup.py install

