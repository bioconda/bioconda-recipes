#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/bin/isoformchecklib"

cp src/IsoformCheck "${PREFIX}/bin"
cp src/isoformchecklib/Analysis.py "${PREFIX}/bin/isoformchecklib"
cp src/isoformchecklib/DatabaseOperations.py "${PREFIX}/bin/isoformchecklib"
cp src/isoformchecklib/Gff3Parser.py "${PREFIX}/bin/isoformchecklib"
cp src/isoformchecklib/HandleAssembly.py "${PREFIX}/bin/isoformchecklib"
cp src/isoformchecklib/__init__.py "${PREFIX}/bin/isoformchecklib"
cp src/isoformchecklib/SequenceReader.py "${PREFIX}/bin/isoformchecklib"
cp src/isoformchecklib/TranscriptExtractor.py "${PREFIX}/bin/isoformchecklib"
cp src/isoformchecklib/Util.py "${PREFIX}/bin/isoformchecklib"
