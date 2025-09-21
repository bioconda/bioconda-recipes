#!/bin/bash
mkdir -p "${PREFIX}/bin"

make LongTR DenovoFinder PhasingChecker

cp LongTR "${PREFIX}/bin/"