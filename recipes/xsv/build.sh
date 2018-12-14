#!/bin/bash

if [ "$(uname -s)" == "Darwin" ]; then
	cargo build --release
	mkdir -p $PREFIX/bin
	cp target/release/xsv $PREFIX/bin
else
	mkdir -p $PREFIX/bin
	cp xsv $PREFIX/bin
fi
