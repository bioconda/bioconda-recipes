#!/bin/sh
set -x -e

# run the test example
ltr_finder ${PREFIX}/share/LTR_Finder/source/test/3ds_72.fa -P 3ds_72 -w2 -f /dev/stderr 2>&1
