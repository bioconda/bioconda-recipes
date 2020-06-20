#!/bin/bash


# move all files to outdir and link into it by bin executor
mkdir -p $PREFIX/bin
cp -R * $PREFIX/bin
chmod a+x $PREFIX/bin/runPolySTestCLI.R
cp polystest.yml $PREFIX
cp LiverAllProteins.csv $PREFIX



