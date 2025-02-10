#!/bin/bash

mkdir -p $PREFIX/bin

mkdir -p $PREFIX/opt/milonga/

cp -r * $PREFIX/opt/milonga/

ln -s $PREFIX/opt/milonga/milonga.py $PREFIX/opt/milonga/scripts/create_hybrid_samplesheet.sh $PREFIX/opt/milonga/scripts/milonga_setup.sh $PREFIX/bin/

chmod -R u+x $PREFIX/bin/*

