#!/bin/bash

mkdir -p ${PREFIX}/bin
make
cp bin/peakranger ${PREFIX}/bin
