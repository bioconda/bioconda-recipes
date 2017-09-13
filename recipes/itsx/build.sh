#!/bin/bash

mkdir -p $PREFIX/bin

mv ITSx $PREFIX/bin
mv ITSx_db/ $PREFIX/bin/
chmod +x $PREFIX/bin/ITSx
