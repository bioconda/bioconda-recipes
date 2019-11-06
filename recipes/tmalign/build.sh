#!/bin/bash

FFLAGS="-O3 -ffast-math -lm"

# backup to "gfortran" in conda GFORTRAN is not set
GFORTRAN=${GFORTRAN:-gfortran}

mkdir -p ${PREFIX}/bin
$GFORTRAN $FFLAGS -o "$PREFIX/bin/TMalign" TMalign.f
$GFORTRAN $FFLAGS -o "$PREFIX/bin/TMscore" TMscore.f
