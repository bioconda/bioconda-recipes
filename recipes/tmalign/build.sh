#!/bin/bash

FFLAGS="-O3 -ffast-math -lm"

$GFORTRAN $FFLAGS -o "$PREFIX/bin/TMalign" TMalign.f
$GFORTRAN $FFLAGS -o "$PREFIX/bin/TMscore" TMscore.f
