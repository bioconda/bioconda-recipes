#!/usr/bin/env bash
# conda-build entry point. Kept separate from the inline script in meta.yaml so
# the same steps work when building from a local checkout.
set -euo pipefail

make -j"${CPU_COUNT:-4}" CXX="${CXX:-g++}"

mkdir -p "${PREFIX}/bin"
install -m 0755 tesseract-asm "${PREFIX}/bin/tesseract-asm"
install -m 0755 tesseract-model "${PREFIX}/bin/tesseract-model"

# The Klebsiella runner ships too, as `tesseract-klebsiella`. Without it an installed package
# is the assembler and nothing else: the user still has to find the release page, download a
# 339 MB model by hand and work out the flags. The script finds the model, checks it and
# assembles, which is the difference between "installed" and "usable".
#
# It resolves the assembler as $(dirname $0)/tesseract-asm, which in an installed tree is the
# TesserACT sitting beside it -- so the installed copy uses the installed binary, not whatever
# happens to be on PATH.
install -m 0755 tesseract-klebsiella "${PREFIX}/bin/tesseract-klebsiella"
