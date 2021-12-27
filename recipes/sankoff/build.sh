#!/bin/bash

set -x -e

make
mkdir -p ${PREFIX}/bin/
cp build/sankoff ${PREFIX}/bin/sankoff
