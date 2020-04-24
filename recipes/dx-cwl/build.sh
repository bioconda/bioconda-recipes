#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"

sed -i.bak 's#!/usr/bin/env python#!/opt/anaconda1anaconda2anaconda3/bin/python#' dx-cwl
mv dx-cwl $TGT
mv dx-cwl-applet-code.py $TGT
mv dx-cwl-postprocess-output-code.py $TGT
mv resources $TGT
ln -s $TGT/dx-cwl $PREFIX/bin
chmod 0755 "${PREFIX}/bin/dx-cwl"
