#!/bin/bash

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
	aarch64) sed -i.bak "s|-march=core2 -mssse3|-march=armv8-a|g" Makefile && rm -f *.bak ;;
	arm64) sed -i.bak "s|-march=core2 -mssse3|-march=armv8.4-a|g" Makefile && rm -f *.bak ;;
	x86_64) sed -i.bak "s|-march=core2 -mssse3|-march=x86-64 -mssse3|g" Makefile && rm -f *.bak ;;
esac

make CC="${CC}"

install -v -m 0755 SeqPrep "${PREFIX}/bin"
