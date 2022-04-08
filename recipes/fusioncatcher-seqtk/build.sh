#!/bin/bash

make

mkdir -p "${PREFIX}/bin"
cp seqtk "${PREFIX}/bin/"
