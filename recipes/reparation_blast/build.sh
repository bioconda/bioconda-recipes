#!/bin/bash

cp reparation.pl ${PREFIX}/bin/
chmod 755 ${PREFIX}/bin/reparation.pl

mkdir -p ${PREFIX}/bin/scripts/
cp scripts/*.pl ${PREFIX}/bin/scripts/
cp scripts/*.py ${PREFIX}/bin/scripts/
cp scripts/*.R ${PREFIX}/bin/scripts/

chmod 755 ${PREFIX}/bin/scripts/*
