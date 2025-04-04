#!/bin/bash
gcc -o esimsa esimsa.c -lm
cp $SRC_DIR/esimsa $PREFIX/bin/esimsa
chmod +x $PREFIX/bin/esimsa