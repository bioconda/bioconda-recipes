#!/bin/bash

# No proper install procedure, need to hack
PERL_VERSION=$(perl -e 'print substr($^V, 1)')
TARGET="$PREFIX/lib/site_perl/$PERL_VERSION/"

mkdir -p "$TARGET"
cp -r modules/Bio/ "$TARGET"
