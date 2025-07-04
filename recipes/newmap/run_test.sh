#!/usr/bin/env bash

newmap --help
newmap index --help
newmap search --help
newmap track --help

# Move data copied over from source_files into original directory structure
mkdir -p data
mv *.fa data/
./run_all.sh
