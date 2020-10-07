#!/bin/sh

# Export path to pkconfig lib files required to install Ocaml packages
export PKG_CONFIG_PATH=$BUILD_PREFIX/lib/pkgconfig

# Create bin and tests folder
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/tests

# Download and compile Opam (Ocaml package manager) to install Ocaml dependencies
wget https://github.com/ocaml/opam/releases/download/2.0.5/opam-full-2.0.5.tar.gz
tar -xf opam-full-2.0.5.tar.gz
cd opam-full-2.0.5
./configure
make lib-ext  # Build dependencies included in the archive
make

# Setup opam environment
./opam init -a --disable-sandboxing
eval $(./opam env)

# Install OCaml dependencies
./opam install batteries ocaml-twt gsl ocamlfind -y

# Build PhyloCSF
cd ..
make

# Give execution permission to binary
chmod +x PhyloCSF

# Move binary to bin folder
cp PhyloCSF $PREFIX/bin
cp PhyloCSF.*.x86_64 $PREFIX/bin
cp -r PhyloCSF_Parameters $PREFIX/bin
cp PhyloCSF_Examples/tal-AA.fa $PREFIX/bin
