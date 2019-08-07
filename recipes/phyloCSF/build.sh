#!/bin/sh

# Install OCaml dependencies
opam install batteries ocaml-twt gsl

# Create bin folder
mkdir -p $PREFIX/bin

# Build PhyloCSF
make

# Give execution permission to binary
chmod +x PhyloCSF

# Move binary to bin folder
mv PhyloCSF $PREFIX/bin
mv PhyloCSF.Linux.x86_64 $PREFIX/bin
mv PhyloCSF_Parameters $PREFIX/bin
