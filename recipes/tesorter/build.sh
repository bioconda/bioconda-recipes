#!/bin/sh
set -x -e

sh build_database.sh
ln -s TEsorter.py ${PREFIX}/bin/TEsorter.py
