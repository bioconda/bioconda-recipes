#!/bin/bash
make
mkdir -p "${PREFIX}/bin"
cp mlRho "${PREFIX}/bin/"
