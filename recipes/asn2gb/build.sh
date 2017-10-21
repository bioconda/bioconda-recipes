#!/bin/bash
set -e

gunzip $SRC_DIR/*asn2gb.gz
mkdir -p "$PREFIX/bin"
cp "$SRC_DIR"/*.asn2gb "$PREFIX/bin/asn2gb"
chmod +x "$PREFIX/bin/tbl2asn"

