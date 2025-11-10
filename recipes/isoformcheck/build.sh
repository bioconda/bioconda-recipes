#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/bin/isoformchecklib"

cp src/IsoformCheck "${PREFIX}/bin"
cp src/isoformchecklib/*.py "${PREFIX}/bin/isoformchecklib"
