#! /bin/bash

outdir=$PREFIX/share/plugins/

mkdir -p "$outdir"

cp simple-omero-client-*.jar "$outdir/"
