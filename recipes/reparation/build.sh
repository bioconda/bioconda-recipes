#!/bin/bash

cp reparation.pl ${prefix}/bin/
chmod 755 ${prefix}/bin/reparation.pl

mkdir ${prefix}/bin/scripts/
cp scripts/* ${PREFIX}/bin/scripts/
chmod 755 ${PREFIX}/bin/scripts/*
