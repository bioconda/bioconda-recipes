#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/bin/isoformcheck_lib"

cp src/IsoformCheck "${PREFIX}/bin"
cp src/isoformcheck_lib/*.py "${PREFIX}/bin/isoformcheck_lib"
