#!/bin/bash

mkdir -p ${PREFIX}/bin
cp -r "vclust-{{ version }}_{{ system }}/"* ${PREFIX}/bin