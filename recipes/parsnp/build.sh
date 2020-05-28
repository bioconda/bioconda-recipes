#!/bin/bash


mkdir -p  "$PREFIX/bin"
>&2 echo $PWD
>&2 ls
./build_parsnp.sh

cp template.ini parsnp Parsnp.py bin/ muscle/ $PREFIX/bin/ -r

