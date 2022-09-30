#!/bin/bash

make
cp $SRC_DIR/bufet.bin $PREFIX/bin/
cp $SRC_DIR/bufet.py $PREFIX/bin/
chmod +x $PREFIX/bin/bufet.bin
chmod +x $PREFIX/bin/bufet.py