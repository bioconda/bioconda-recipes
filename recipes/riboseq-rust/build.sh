#!/bin/bash
mkdir -p "$PREFIX/bin"
for j in rust_*; do
	sed -i.bak '1 s|^.*$|#!/usr/bin/env python2|g' "${j}"
done
chmod 755 rust_*
cp rust_* $PREFIX/bin
