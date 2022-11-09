#!/bin/bash
mkdir -p "$PREFIX/bin"
cp kent/src/utils/ucscApiClient "$PREFIX/bin"
chmod +x "$PREFIX/bin/ucscApiClient"
