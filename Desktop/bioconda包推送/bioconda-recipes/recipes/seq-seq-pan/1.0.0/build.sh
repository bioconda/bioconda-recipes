#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/seq-seq-pan/


sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/seq-seq-pan|g" seq-seq-pan
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/seq-seq-pan|g" seq-seq-pan-consensus
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/seq-seq-pan|g" seq-seq-pan-wga
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/seq-seq-pan|g" seq-seq-pan-genomedescription

cp -r * $PREFIX/opt/seq-seq-pan/
ln -s $PREFIX/opt/seq-seq-pan/seq-seq-pan $PREFIX/bin
ln -s $PREFIX/opt/seq-seq-pan/seq-seq-pan-consensus $PREFIX/bin
ln -s $PREFIX/opt/seq-seq-pan/seq-seq-pan-wga $PREFIX/bin
ln -s $PREFIX/opt/seq-seq-pan/seq-seq-pan-genomedescription $PREFIX/bin
