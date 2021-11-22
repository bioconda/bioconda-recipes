#!/bin/sh
set -e

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/docs"
mkdir -p "${PREFIX}/snakemake"
mkdir -p "${PREFIX}/test_data"

cp -r bin/* "${PREFIX}/bin/"
cp -r docs/* "${PREFIX}/docs/"
cp -r snakemake/* "${PREFIX}/snakemake/"
cp -r test_data/* "${PREFIX}/test_data/"
cp -r mkdocs.yml LICENSE README.md VERSION "${PREFIX}/"

hecatomb -h
