#!/bin/bash
cd flock/src
cc -o $PREFIX/bin/flock1 flock1.c find_connected.c -lm
cc -o $PREFIX/bin/flock2 flock2.c -lm
cc -o $PREFIX/bin/cent_adjust cent_adjust.c -lm
