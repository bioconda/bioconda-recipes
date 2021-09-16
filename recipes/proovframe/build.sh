#!/bin/bash

# No proper install procedure, need to hack
PERL_VERSION=$(perl -e 'print substr($^V, 1)')
LIB_TARGET="$PREFIX/lib/site_perl/$PERL_VERSION/"

mkdir -p "$LIB_TARGET"
cp -r lib/Fasta/ "$LIB_TARGET"

cp bin/* "$PREFIX/bin/"
