#!/bin/sh
gcc -O3 -ffast-math -finline-functions -o aragorn aragorn1.2.36.c
mv aragorn $PREFIX
