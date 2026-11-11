#!/usr/bin/env bash

newmap --help
newmap index --help
newmap search --help
newmap track --help

pushd tests
./test_end_to_end.sh
popd
