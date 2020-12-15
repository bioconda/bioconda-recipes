#!/bin/bash

mkdir -p $PREFIX/bin

cp aquamis.py $PREFIX/bin/aquamis

cp scripts/*.py scripts/*.R scripts/*.sh $PREFIX/bin/

chmod -R u+x $PREFIX/bin/*.sh $PREFIX/bin/*.R $PREFIX/bin/*.py $PREFIX/bin/aquamis 
