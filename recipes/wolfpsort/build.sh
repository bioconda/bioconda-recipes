#!/bin/sh

# Setup the wrapper scripts under ${PREFIX}/bin/
mkdir -p "${PREFIX}/bin"
mv "${RECIPE_DIR}/runWolfPsortSummary.py" "${PREFIX}/bin/runWolfPsortSummary"
mv "${RECIPE_DIR}/runWolfPsortHtmlTables.py" "${PREFIX}/bin/runWolfPsortHtmlTables"
chmod 0755 "${PREFIX}/bin/runWolfPsortSummary"
chmod 0755 "${PREFIX}/bin/runWolfPsortHtmlTables"

# Setup tool itself under ${PREFIX}/opt/
#
# WoLF PSORT comes with internal binaries for i386 and SPARC only:
# - runAddAlignmentToHtml
# - wolfPredict
# - WoLFPSORTpredictAndAlign
cp bin/binByPlatform/binary-i386/* bin/
mkdir -p ${PREFIX}/opt
mv * ${PREFIX}/opt/
