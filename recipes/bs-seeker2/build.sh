#!/bin/bash

mkdir -p $PREFIX/bin/
rm -rf galaxy
cp -r * $PREFIX/bin/
chmod a+x $PREFIX/bin/bs_seeker2-align.py
chmod a+x $PREFIX/bin/bs_seeker2-build.py
chmod a+x $PREFIX/bin/bs_seeker2-call_methylation.py
