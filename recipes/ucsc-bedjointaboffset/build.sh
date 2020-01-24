#!/bin/bash
mkdir -p "$PREFIX/bin"
cp kent/src/utils/bedJoinTabOffset "$PREFIX/bin"
chmod +x "$PREFIX/bin/bedJoinTabOffset"
