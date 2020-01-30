#!/bin/bash

cp ./sigprofiler ${PREFIX}/bin/sigprofiler
cp -r ./lib_repo ${PREFIX}/bin/lib_repo
chmod u+rwx $PREFIX/bin/lib_repo/scripts/*
chmod u+rwx $PREFIX/bin/lib_repo/SigProfPlot/sigProfilerPlotting/*
chmod u+rwx $PREFIX/bin/*
