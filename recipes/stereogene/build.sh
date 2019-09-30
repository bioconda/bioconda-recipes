#!/bin/bash

mkdir -p ${PREFIX}/bin

cd src
mv Smoother.cpp smoother.cpp
mv Binning.cpp binning.cpp
make
cp {StereoGene,Binner,Confounder,ParseGenes,Projector,Smoother} ${PREFIX}/bin
