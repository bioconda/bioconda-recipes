#!/bin/bash

mkdir -p $PREFIX/bin

chmod +x BuildSuperTranscript.py
chmod +x Checker.py
chmod +x Lace.py
chmod +x Mobius.py
chmod +x STViewer.py

cp BuildSuperTranscript.py $PREFIX/bin
cp Checker.py  $PREFIX/bin/Lace_Checker.py
cp  Lace.py $PREFIX/bin
cp  Mobius.py $PREFIX/bin
cp  STViewer.py $PREFIX/bin

