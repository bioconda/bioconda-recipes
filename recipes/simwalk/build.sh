#!/bin/bash

gcc -lm -lgfortran -o simwalk2 CODE/nomendel.f CODE/simwalk2.f -v

cp simwalk2 $PREFIX/bin

