#!/bin/bash

make

mkdir -p $PREFIX/bin
cp miniprot_boundary_scorer $PREFIX/bin