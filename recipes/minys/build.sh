#!/bin/bash


make -C graph_simplification/nwalign/

mkdir -p $PREFIX/bin
ln -s  MinYS.py  ${PREFIX}/bin/
ln -s graph_simplification/enumerate_paths.py  ${PREFIX}/bin/
ln -s graph_simplification/filter_coomponents.py  ${PREFIX}/bin/
ln -s graph_simplification/graph_simplification.py  ${PREFIX}/bin/

