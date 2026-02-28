#!/bin/bash

# No proper install procedure, need to hack
PERL_VERSION=$(perl -e 'print substr($^V, 1)')
TARGET="$PREFIX/lib/perl5/site_perl/"

mkdir -p "$TARGET"
cp -r modules/Bio/ "$TARGET"
