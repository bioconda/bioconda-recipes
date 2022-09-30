#!/bin/bash

sed -i s#MUGSY_INSTALL=./mugsy_x86-64-v1r2.3#MUGSY_INSTALL=${PREFIX}/bin#g ${PREFIX}/etc/conda/activate.d/mugsyenv.sh
