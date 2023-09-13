#!/bin/bash
mkdir -p ${PREFIX}/bin
ls -lh py/freddie_split.py
cp -f py/freddie_split.py ${PREFIX}/bin 
ls -lh py/freddie_segment.py
cp -f py/freddie_segment.py ${PREFIX}/bin 
ls -lh py/freddie_cluster.py
cp -f py/freddie_cluster.py ${PREFIX}/bin 
ls -lh py/freddie_isoforms.py
cp -f py/freddie_isoforms.py ${PREFIX}/bin 
