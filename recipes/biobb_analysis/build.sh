#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_analysis/gromacs/gmx_rms.py
cp $SP_DIR/biobb_analysis/gromacs/gmx_rms.py $PREFIX/bin/gmx_rms

chmod u+x $SP_DIR/biobb_analysis/gromacs/gmx_cluster.py
cp $SP_DIR/biobb_analysis/gromacs/gmx_cluster.py $PREFIX/bin/gmx_cluster

chmod u+x $SP_DIR/biobb_analysis/gromacs/gmx_energy.py
cp $SP_DIR/biobb_analysis/gromacs/gmx_energy.py $PREFIX/bin/gmx_energy

chmod u+x $SP_DIR/biobb_analysis/gromacs/gmx_rgyr.py
cp $SP_DIR/biobb_analysis/gromacs/gmx_rgyr.py $PREFIX/bin/gmx_rgyr

chmod u+x $SP_DIR/biobb_analysis/gromacs/gmx_image.py
cp $SP_DIR/biobb_analysis/gromacs/gmx_image.py $PREFIX/bin/gmx_image

chmod u+x $SP_DIR/biobb_analysis/gromacs/gmx_trjconv_str.py
cp $SP_DIR/biobb_analysis/gromacs/gmx_trjconv_str.py $PREFIX/bin/gmx_trjconv_str

chmod u+x $SP_DIR/biobb_analysis/gromacs/gmx_trjconv_str_ens.py
cp $SP_DIR/biobb_analysis/gromacs/gmx_trjconv_str_ens.py $PREFIX/bin/gmx_trjconv_str_ens

chmod u+x $SP_DIR/biobb_analysis/gromacs/gmx_trjconv_trj.py
cp $SP_DIR/biobb_analysis/gromacs/gmx_trjconv_trj.py $PREFIX/bin/gmx_trjconv_trj

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_input.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_input.py $PREFIX/bin/cpptraj_input

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_average.py $PREFIX/bin/cpptraj_average

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_bfactor.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_bfactor.py $PREFIX/bin/cpptraj_bfactor

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_convert.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_convert.py $PREFIX/bin/cpptraj_convert

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_dry.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_dry.py $PREFIX/bin/cpptraj_dry

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_image.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_image.py $PREFIX/bin/cpptraj_image

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_mask.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_mask.py $PREFIX/bin/cpptraj_mask

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_rgyr.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_rgyr.py $PREFIX/bin/cpptraj_rgyr

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_rms.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_rms.py $PREFIX/bin/cpptraj_rms

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_rmsf.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_rmsf.py $PREFIX/bin/cpptraj_rmsf

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_slice.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_slice.py $PREFIX/bin/cpptraj_slice

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_snapshot.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_snapshot.py $PREFIX/bin/cpptraj_snapshot

chmod u+x $SP_DIR/biobb_analysis/ambertools/cpptraj_strip.py
cp $SP_DIR/biobb_analysis/ambertools/cpptraj_strip.py $PREFIX/bin/cpptraj_strip
