#!/bin/bash

mkdir -p ${PREFIX}/bin

make CC=$CC
cp src/gbmunge ${PREFIX}/bin/
