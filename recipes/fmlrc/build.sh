#!/bin/bash
mkdir -p ${PREFIX}/bin

make
mv fmlrc ${PREFIX}/bin/
