#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make bwa/libbwa.a
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
