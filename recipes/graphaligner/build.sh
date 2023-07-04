#!/usr/bin/env bash
ls -l $PREFIX/lib
make all
cp bin/GraphAligner $PREFIX/bin
