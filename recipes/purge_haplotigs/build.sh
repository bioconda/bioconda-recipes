#!/bin/bash

mkdir -p  "$PREFIX/bin"

cp -r bin/ $PREFIX
cp -r scripts/ $PREFIX
cp -r lib/ $PREFIX
cp -r test/ $PREFIX
