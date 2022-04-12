#!/bin/bash
make

mkdir -p "$PREFIX"/bin
cp Gassst "$PREFIX"/bin/Gassst
