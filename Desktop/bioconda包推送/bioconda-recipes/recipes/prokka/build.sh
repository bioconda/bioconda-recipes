#!/bin/sh
set -e

rm -rf ./binaries
rm -f bin/prokka-make_tarball 

./bin/prokka --setupdb

mkdir -p "${PREFIX}/bin" "${PREFIX}/db" "${PREFIX}/share/doc/prokka"
mv bin/* "${PREFIX}/bin/"
mv db/* "${PREFIX}/db/"
cp -r doc/* "${PREFIX}/share/doc/prokka/"

prokka --listdb
prokka --version
prokka --citation
