#!/bin/bash


make -C graph_simplification/nwalign/

mkdir -p $PREFIX/bin/
cp  MinYS.py  ${PREFIX}/bin/
cp -r minys_utils  ${PREFIX}/bin/
cp -r graph_simplification  ${PREFIX}/bin/
