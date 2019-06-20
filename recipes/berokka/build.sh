#!/bin/bash

mkdir -p  "$PREFIX/bin"

cp bin/berokka $PREFIX/bin/
cp -a db/. $PREFIX/db/

