#!/bin/bash

mkdir -p  "$PREFIX/bin"
./build_parsnp.sh

cp template.ini parsnp Parsnp.py bin/ muscle/ $PREFIX/bin/ -r

