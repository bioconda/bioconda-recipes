#!/bin/bash

set -e
./sigprofiler -h
cp -r * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/lib_repo/scripts/*
chmod u+rwx $PREFIX/bin/lib_repo/SigProfPlot/sigProfilerPlotting/*
chmod u+rwx $PREFIX/bin/*
