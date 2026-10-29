#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/site-packages"
mkdir -p "${PREFIX}/site-packages/isoformchecklib"

cp src/IsoformCheck "${PREFIX}/bin"
cp src/isoformchecklib/Analysis.py "${PREFIX}/site-packages/isoformchecklib"
cp src/isoformchecklib/DatabaseOperations.py "${PREFIX}/site-packages/isoformchecklib"
cp src/isoformchecklib/Gff3Parser.py "${PREFIX}/site-packages/isoformchecklib"
cp src/isoformchecklib/HandleAssembly.py "${PREFIX}/site-packages/isoformchecklib"
cp src/isoformchecklib/__init__.py "${PREFIX}/site-packages/isoformchecklib"
cp src/isoformchecklib/SequenceReader.py "${PREFIX}/site-packages/isoformchecklib"
cp src/isoformchecklib/TranscriptExtractor.py "${PREFIX}/site-packages/isoformchecklib"
cp src/isoformchecklib/Util.py "${PREFIX}/site-packages/isoformchecklib"
