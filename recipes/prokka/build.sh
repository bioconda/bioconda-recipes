#!/bin/sh
set -e

sleep 5

./bin/prokka --setupdb
mkdir -p "${PREFIX}/bin" "${PREFIX}/db" "${PREFIX}/share/doc/prokka"
mv bin/* "${PREFIX}/bin/"
mv db/* "${PREFIX}/db/"
mv doc/* "${PREFIX}/share/doc/prokka/"
