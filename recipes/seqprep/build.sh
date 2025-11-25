#!/bin/bash

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
	aarch64|arm64) sed -i.bak "s|-mssse3||g" Makefile && rm -f *.bak ;;
esac

make CC="${CC}"

install -v -m 0755 SeqPrep "${PREFIX}/bin"
