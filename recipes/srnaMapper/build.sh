#!/bin/bash

make
mkdir -p ${PREFIX}/bin
cp -f srnaMapper ${PREFIX}/bin
