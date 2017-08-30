#!/bin/sh

# Comes with i386 and SPARC binaries,
# - runAddAlignmentToHtml
# - wolfPredict
# - WoLFPSORTpredictAndAlign
cp bin/binByPlatform/binary-i386/* bin/

mv * ${PREFIX}/
