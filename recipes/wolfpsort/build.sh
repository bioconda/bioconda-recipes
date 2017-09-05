#!/bin/sh

# Setup the wrapper scripts under ${PREFIX}/bin/
mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/chdir_wrapper.py" "${PREFIX}/bin/runWolfPsortSummary"
cp "${RECIPE_DIR}/chdir_wrapper.py" "${PREFIX}/bin/runWolfPsortHtmlTables"
chmod 0755 "${PREFIX}/bin/runWolfPsortSummary"
chmod 0755 "${PREFIX}/bin/runWolfPsortHtmlTables"

# Setup tool itself under ${PREFIX}/opt/
#
# WoLF PSORT comes with internal binaries for i386 and SPARC only:
# - runAddAlignmentToHtml
# - wolfPredict
# - WoLFPSORTpredictAndAlign
#
# We remove the SPARC binaries to avoid confusing patchelf.
rm -rf bin/binByPlatform/binary-sparc
chmod 0755 bin/binByPlatform/binary-i386/*
cp bin/binByPlatform/binary-i386/* bin/
mkdir -p ${PREFIX}/opt
mv * ${PREFIX}/opt/

# Copy the license back as the build will look for it in source folder...
cp ${PREFIX}/opt/LICENSE .
