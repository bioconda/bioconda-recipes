#!/usr/bin/env bash
set -Eeuo pipefail

install -d "$PREFIX/bin"
install -m 0755 "bin/fufihla" "$PREFIX/bin/"
install -m 0755 "bin/fufihla-ref-prep" "$PREFIX/bin/"

install -d "$PREFIX/share/fufihla"
cp -r "share/fufihla/"* "$PREFIX/share/fufihla/"

chmod 0755 "$PREFIX/share/fufihla/scripts/FuFiHLA.sh" || true
chmod 0755 "$PREFIX/share/fufihla/scripts/FuFiHLA_nano.sh" || true
chmod 0755 "$PREFIX/share/fufihla/ref/ref-prep.sh" || true
