#!/bin/bash

cd src/

# enable mpi
echo "yes" | perl Build.PL

./Build install
