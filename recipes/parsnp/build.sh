#!/bin/bash

mkdir -p  "$PREFIX/bin"

cp template.ini parsnp Parsnp.py bin/ muscle/ $PREFIX/bin/ -r

