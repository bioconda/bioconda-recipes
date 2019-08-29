#!/bin/sh
set -e

rm -rf ./binaries ./perl5

./bin/prokka --setupdb

mkdir -p "${PREFIX}/bin" "${PREFIX}/db" "${PREFIX}/share/doc/prokka"
mv bin/* "${PREFIX}/bin/"
mv db/* "${PREFIX}/db/"
mv doc/* "${PREFIX}/share/doc/prokka/"

prokka --listdb
prokka --version
