#!/bin/bash
mkdir -p "${PREFIX}/bin"

make

cp LongTR "${PREFIX}/bin/"