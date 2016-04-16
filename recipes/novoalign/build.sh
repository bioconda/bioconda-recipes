#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
chmod a+x *novo*
cp isnovoindex novo2paf novoalign novoalignCS novoalignCSMPI novoalignMPI novobarcode novoindex novomethyl novope2bed.pl novorun.pl novosort novoutil novo2sam.pl $PREFIX/bin
