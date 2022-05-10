#!/bin/bash
mkdir -p "$PREFIX"/bin
make release
mv gffread "$PREFIX"/bin 