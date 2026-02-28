#!/bin/sh
set -e

mkdir -p "${PREFIX}/bin" 
mv bin/* "${PREFIX}/bin/"

prokka --version
metaprokka --version