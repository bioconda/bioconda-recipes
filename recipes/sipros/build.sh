#!/bin/bash
set -e

mkdir -p "$PREFIX/bin"
chmod u+x bin/*
cp -r bin/* "$PREFIX/bin"

cp -r EnsembleScripts "$PREFIX"
cp -r V4Scripts "$PREFIX"

cp -r configTemplates "$PREFIX"

cp $RECIPE_DIR/Raxport.sh "$PREFIX/bin/Raxport"
chmod +x "$PREFIX/bin/Raxport"