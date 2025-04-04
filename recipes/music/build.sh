#!/bin/sh
make clean
make

cp bin/* $PREFIX/bin

chmod +x $PREFIX/bin/MUSIC
chmod +x $PREFIX/bin/generate_multimappability_signal.csh
chmod +x $PREFIX/bin/run_MUSIC.csh

