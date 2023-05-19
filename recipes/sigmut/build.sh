#!/bin/bash

set -e
mkdir -p $PREFIX/bin
cp sigprofiler ${PREFIX}/bin/
cp -r lib_repo ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/lib_repo/scripts/*
chmod u+rwx $PREFIX/bin/lib_repo/SigProfPlot/sigProfilerPlotting/*
chmod u+rwx $PREFIX/bin/*
