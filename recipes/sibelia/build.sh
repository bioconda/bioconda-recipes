#!/bin/bash
mkdir -p ${PREFIX}/bin ${PREFIX}/lib ${PREFIX}/share
cp -r bin/*  ${PREFIX}/bin
cp -r lib/Sibelia/* ${PREFIX}/lib
cp -r share/Sibelia/* ${PREFIX}/share
