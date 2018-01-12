#!/bin/bash
mkdir -p "$PREFIX/bin"
for j in *.py; do
	sed -i.bak '1 s|^.*$|#!/usr/bin/env python2|g' "${j}"
done
chmod 755 *.py
cp * $PREFIX/bin
