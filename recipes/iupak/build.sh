#!/usr/bin/env bash
set -eu

# should use "install -m 755 ...." here
mkdir -p "${PREFIX}/bin"
chmod 755 any2fasta
cp any2fasta "${PREFIX}/bin/"

