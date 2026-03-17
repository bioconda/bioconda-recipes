#!/usr/bin/env bash

newmap --help
newmap index --help
newmap search --help
newmap track --help

pushd tests
./run_all.sh
popd
