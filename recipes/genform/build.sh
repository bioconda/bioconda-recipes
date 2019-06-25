#!/bin/bash

${CXX} ./src/*.cpp -o genform
mkdir -p "$PREFIX"/bin/
mv genform "$PREFIX"/bin/
