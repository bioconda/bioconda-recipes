#!/bin/bash

mkdir -p $PREFIX/bin

make 

chmod +x  src/lastz
chmod +x  src/lastz

mv src/lastz $PREFIX/bin
mv src/lastz_D $PREFIX/bin

