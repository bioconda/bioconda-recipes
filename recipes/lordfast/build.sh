#!/bin/bash

make
mkdir -p "${PREFIX}/bin"
cp lordfast "${PREFIX}/bin/"
