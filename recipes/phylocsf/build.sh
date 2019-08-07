#!/bin/sh

# Create bin folder
mkdir -p $PREFIX/bin

# Download and compile Opam to install Ocaml dependencies
wget https://github.com/ocaml/opam/releases/download/2.0.5/opam-full-2.0.5.tar.gz
tar -xf opam-full-2.0.5.tar.gz
cd opam-full-2.0.5
./configure
make lib-ext
make
cp opam $PREFIX/bin

# Install OCaml dependencies
opam install batteries ocaml-twt gsl

# Build PhyloCSF
make

# Give execution permission to binary
chmod +x PhyloCSF

# Move binary to bin folder
mv PhyloCSF $PREFIX/bin
mv PhyloCSF.Linux.x86_64 $PREFIX/bin
mv PhyloCSF_Parameters $PREFIX/bin
