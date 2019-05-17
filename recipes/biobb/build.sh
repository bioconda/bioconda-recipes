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

chmod u+x $SP_DIR/biobb_pmx/pmx/mutate.py
cp $SP_DIR/biobb_pmx/pmx/mutate.py $PREFIX/bin/mutate

chmod u+x $SP_DIR/biobb_pmx/pmx/analyse.py
cp $SP_DIR/biobb_pmx/pmx/analyse.py $PREFIX/bin/analyse

chmod u+x $SP_DIR/biobb_pmx/pmx/gentop.py
cp $SP_DIR/biobb_pmx/pmx/gentop.py $PREFIX/bin/gentop

chmod u+x $SP_DIR/biobb_model/model/mutate.py
cp $SP_DIR/biobb_model/model/mutate.py $PREFIX/bin/mutate

chmod u+x $SP_DIR/biobb_model/model/fix_side_chain.py
cp $SP_DIR/biobb_model/model/fix_side_chain.py $PREFIX/bin/fix_side_chain

chmod u+x $SP_DIR/biobb_md/gromacs/editconf.py
cp $SP_DIR/biobb_md/gromacs/editconf.py $PREFIX/bin/editconf

chmod u+x $SP_DIR/biobb_md/gromacs/genion.py
cp $SP_DIR/biobb_md/gromacs/genion.py $PREFIX/bin/genion

chmod u+x $SP_DIR/biobb_md/gromacs/genrestr.py
cp $SP_DIR/biobb_md/gromacs/genrestr.py $PREFIX/bin/genrestr

chmod u+x $SP_DIR/biobb_md/gromacs/grompp.py
cp $SP_DIR/biobb_md/gromacs/grompp.py $PREFIX/bin/grompp

chmod u+x $SP_DIR/biobb_md/gromacs/make_ndx.py
cp $SP_DIR/biobb_md/gromacs/make_ndx.py $PREFIX/bin/make_ndx

chmod u+x $SP_DIR/biobb_md/gromacs/mdrun.py
cp $SP_DIR/biobb_md/gromacs/mdrun.py $PREFIX/bin/mdrun

chmod u+x $SP_DIR/biobb_md/gromacs/pdb2gmx.py
cp $SP_DIR/biobb_md/gromacs/pdb2gmx.py $PREFIX/bin/pdb2gmx

chmod u+x $SP_DIR/biobb_md/gromacs/solvate.py
cp $SP_DIR/biobb_md/gromacs/solvate.py $PREFIX/bin/solvate

chmod u+x $SP_DIR/biobb_md/gromacs_extra/ndx2resttop.py
cp $SP_DIR/biobb_md/gromacs_extra/ndx2resttop.py $PREFIX/bin/ndx2resttop

chmod u+x $SP_DIR/biobb_md/gromacs_extra/append_ligand.py
cp $SP_DIR/biobb_md/gromacs_extra/append_ligand.py $PREFIX/bin/append_ligand

chmod u+x $SP_DIR/biobb_io/api/pdb.py
cp $SP_DIR/biobb_io/api/pdb.py $PREFIX/bin/pdb

chmod u+x $SP_DIR/biobb_io/api/pdb_cluster_zip.py
cp $SP_DIR/biobb_io/api/pdb_cluster_zip.py $PREFIX/bin/pdb_cluster_zip

chmod u+x $SP_DIR/biobb_io/api/pdb_variants.py
cp $SP_DIR/biobb_io/api/pdb_variants.py $PREFIX/bin/pdb_variants

chmod u+x $SP_DIR/biobb_chemistry/acpype/acpype_params_ac.py
cp $SP_DIR/biobb_chemistry/acpype/acpype_params_ac.py $PREFIX/bin/acpype_params_ac

chmod u+x $SP_DIR/biobb_chemistry/acpype/acpype_params_cns.py
cp $SP_DIR/biobb_chemistry/acpype/acpype_params_cns.py $PREFIX/bin/acpype_params_cns

chmod u+x $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx.py
cp $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx.py $PREFIX/bin/acpype_params_gmx

chmod u+x $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx_opls.py
cp $SP_DIR/biobb_chemistry/acpype/acpype_params_gmx_opls.py $PREFIX/bin/acpype_params_gmx_opls

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_add_hydrogens.py
cp $SP_DIR/biobb_chemistry/babelm/babel_add_hydrogens.py $PREFIX/bin/babel_add_hydrogens

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_convert.py
cp $SP_DIR/biobb_chemistry/babelm/babel_convert.py $PREFIX/bin/babel_convert

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_minimize.py
cp $SP_DIR/biobb_chemistry/babelm/babel_minimize.py $PREFIX/bin/babel_minimize

chmod u+x $SP_DIR/biobb_chemistry/babelm/babel_remove_hydrogens.py
cp $SP_DIR/biobb_chemistry/babelm/babel_remove_hydrogens.py $PREFIX/bin/babel_remove_hydrogens

chmod u+x $SP_DIR/biobb_chemistry/ambertools/reduce_add_hydrogens.py
cp $SP_DIR/biobb_chemistry/ambertools/reduce_add_hydrogens.py $PREFIX/bin/reduce_add_hydrogens

chmod u+x $SP_DIR/biobb_chemistry/ambertools/reduce_remove_hydrogens.py
cp $SP_DIR/biobb_chemistry/ambertools/reduce_remove_hydrogens.py $PREFIX/bin/reduce_remove_hydrogens
