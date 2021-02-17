#!/bin/sh
set -e

chmod +x bin/*
#./bin/makedb --setupdb
mkdir -p "${PREFIX}/bin" "${PREFIX}/db"
mv bin/* "${PREFIX}/bin/"

#mv db/* "${PREFIX}/db/"
#cp -r doc/* "${PREFIX}/share/doc/dadaist2/"

