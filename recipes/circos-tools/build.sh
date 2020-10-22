#!/bin/bash

cd tools

mkdir -p $PREFIX/bin/ $PREFIX/lib/
cp binlinks/bin/binlinks $PREFIX/bin/
cp bundlelinks/bin/bundlelinks $PREFIX/bin/
cp calcdatarange/bin/calcdatarange $PREFIX/bin/
cp categoryviewer/bin/parse-category $PREFIX/bin/
cp clustal2link/bin/clustal2link $PREFIX/bin/
cp colorinterpolate/bin/colorinterpolate $PREFIX/bin/
cp convertlinks/bin/convertlinks $PREFIX/bin/
cp filterlinks/bin/filterlinks $PREFIX/bin/
cp orderchr/bin/orderchr $PREFIX/bin/
cp randomdata/bin/randomdata $PREFIX/bin/
cp randomlinks/bin/randomlinks $PREFIX/bin/
cp resample/bin/resample $PREFIX/bin/
cp tableviewer/bin/make-conf $PREFIX/bin/
cp tableviewer/bin/make-table $PREFIX/bin/
cp tableviewer/bin/parse-table $PREFIX/bin/
cp tableviewer/lib/* $PREFIX/lib/
