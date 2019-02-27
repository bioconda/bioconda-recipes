#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_analysis/gromacs/rms.py
cp $SP_DIR/biobb_analysis/gromacs/rms.py $PREFIX/bin/rms

chmod u+x $SP_DIR/biobb_analysis/gromacs/cluster.py
cp $SP_DIR/biobb_analysis/gromacs/cluster.py $PREFIX/bin/cluster

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj.py $PREFIX/bin/biobb_cpptraj

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_average

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_bfactor.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_bfactor

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_convert.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_convert

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_dry.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_dry

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_image.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_image

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_mask.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_mask

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_rgyr.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_rgyr

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_rms.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_rms

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_rmsf.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_rmsf

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_slice.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_slice

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_snapshot.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_snapshot

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_strip.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/biobb_cpptraj_strip
