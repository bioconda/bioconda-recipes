#!/bin/bash


cd flock
mkdir bin
cd bin
cc -o flock1 ../src/flock1.c ../src/find_connected.c -lm
cc -o flock2 ../src/flock2.c -lm
cc -o cent_adjust ../src/cent_adjust.c -lm
