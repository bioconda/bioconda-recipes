#!/bin/bash

cd $PREFIX/src/olego/
make
cd ../../assemblies_psiclass_modified/
make
cd ../..
chmod -R a+x *
