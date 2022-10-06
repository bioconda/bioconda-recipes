#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/share/PifCoSm

mv PifCoSm.pl $PREFIX/bin
mv lib/ $PREFIX/lib/PifCoSm
mv hmms $PREFIX/share/PifCoSm/
