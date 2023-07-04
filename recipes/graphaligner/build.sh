#!/usr/bin/env bash
ls -l $PREFIX/lib 1>&2 && exit 1
make all
cp bin/GraphAligner $PREFIX/bin
