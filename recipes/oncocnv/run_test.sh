#!/bin/bash

cat testdata/Control.stats.txt | grep -v start | awk '{print $1,$2,$3}' | sed "s/ /\t/g" > target.bed

cat $PREFIX/bin/processControl.R | R --slave --args testdata/Control.stats.txt Control.stats.Processed.txt testdata/target.GC.txt

cat $PREFIX/bin/processSamples.R | R --slave --args testdata/Test.stats.samplesA1_A3.txt Control.stats.Processed.txt Test.output.txt cghseg