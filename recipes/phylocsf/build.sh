#!/bin/sh

# Create bin folder
mkdir -p $PREFIX/bin

echo " ======================= Downloading and compiling Opam ... ======================="

# Download and compile Opam to install Ocaml dependencies
wget https://github.com/ocaml/opam/releases/download/2.0.5/opam-full-2.0.5.tar.gz
tar -xf opam-full-2.0.5.tar.gz
cd opam-full-2.0.5
./configure
make lib-ext
make

echo " ======================= Setting up Opam environment ... ======================="
# Setup opam environment
./opam init -a --disable-sandboxing
eval $(./opam env)

echo " ======================= Testing environment variables ... ======================="
echo "gsl config : " $(gsl-config --libs)
export LD_LIBRARY_PATH=$BUILD_PREFIX/lib
echo "LD_LIB_PATH : " $LD_LIBRARY_PATH

echo " ======================= Testing pkg config ... ======================="
echo "Listing lib dir"
echo $BUILD_PREFIX
ls -a $BUILD_PREFIX/lib
echo "Package config output"
/usr/bin/pkg-config --debug gsl

echo " ======================= Installing OCaml dependencies ... ======================="
# Install OCaml dependencies
# ./opam install batteries ocaml-twt gsl -y
./opam install gsl -y

cd ..
echo " ======================= Building PhyloCSF ... ======================="
# Build PhyloCSF
make

# Give execution permission to binary
chmod +x PhyloCSF

# Move binary to bin folder
cp PhyloCSF $PREFIX/bin
cp PhyloCSF.Linux.x86_64 $PREFIX/bin
cp PhyloCSF_Parameters $PREFIX/bin
