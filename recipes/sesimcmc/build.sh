#!/bin/bash
set -x

cd src/

source activate root

make CC=$CC CPP=$CXX
