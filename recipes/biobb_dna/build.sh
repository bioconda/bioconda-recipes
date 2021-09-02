#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_dna/curvesplus/curves.py
cp $SP_DIR/biobb_dna/curvesplus/curves.py $PREFIX/bin/biobb_curves

chmod u+x $SP_DIR/biobb_dna/curvesplus/canal.py
cp $SP_DIR/biobb_dna/curvesplus/canal.py $PREFIX/bin/biobb_canal

chmod u+x $SP_DIR/biobb_dna/backbone/bipopulations.py
cp $SP_DIR/biobb_dna/backbone/bipopulations.py $PREFIX/bin/bipopulations

chmod u+x $SP_DIR/biobb_dna/backbone/canonical_alpha_gamma.py
cp $SP_DIR/biobb_dna/backbone/canonical_alpha_gamma.py $PREFIX/bin/canonicalag

chmod u+x $SP_DIR/biobb_dna/backbone/puckering.py
cp $SP_DIR/biobb_dna/backbone/puckering.py $PREFIX/bin/puckering

chmod u+x $SP_DIR/biobb_dna/dna/averages.py
cp $SP_DIR/biobb_dna/dna/averages.py $PREFIX/bin/dna_averages

chmod u+x $SP_DIR/biobb_dna/classification/k_neighbors.py
cp $SP_DIR/biobb_dna/classification/k_neighbors.py $PREFIX/bin/k_neighbors

chmod u+x $SP_DIR/biobb_dna/dna/timeseries.py
cp $SP_DIR/biobb_dna/dna/timeseries.py $PREFIX/bin/dna_timeseries

chmod u+x $SP_DIR/biobb_dna/dna/bimodality.py
cp $SP_DIR/biobb_dna/dna/bimodality.py $PREFIX/bin/dna_bimodality

chmod u+x $SP_DIR/biobb_dna/interbp_correlations/basepaircorrelation.py
cp $SP_DIR/biobb_dna/interbp_correlations/basepaircorrelation.py $PREFIX/bin/inter_bpcorr

chmod u+x $SP_DIR/biobb_dna/interbp_correlations/helparcorrelation.py
cp $SP_DIR/biobb_dna/interbp_correlations/helparcorrelation.py $PREFIX/bin/inter_hpcorr

chmod u+x $SP_DIR/biobb_dna/interbp_correlations/sequencecorrelation.py
cp $SP_DIR/biobb_dna/interbp_correlations/sequencecorrelation.py $PREFIX/bin/inter_seqcorr

chmod u+x $SP_DIR/biobb_dna/intrabp_correlations/basepaircorrelation.py
cp $SP_DIR/biobb_dna/intrabp_correlations/basepaircorrelation.py $PREFIX/bin/intra_bpcorr

chmod u+x $SP_DIR/biobb_dna/intrabp_correlations/helparcorrelation.py
cp $SP_DIR/biobb_dna/intrabp_correlations/helparcorrelation.py $PREFIX/bin/intra_hpcorr

chmod u+x $SP_DIR/biobb_dna/intrabp_correlations/sequencecorrelation.py
cp $SP_DIR/biobb_dna/intrabp_correlations/sequencecorrelation.py $PREFIX/bin/intra_seqcorr

chmod u+x $SP_DIR/biobb_dna/stiffness/average_stiffness.py
cp $SP_DIR/biobb_dna/stiffness/average_stiffness.py $PREFIX/bin/avgstiff

chmod u+x $SP_DIR/biobb_dna/stiffness/basepair_stiffness.py
cp $SP_DIR/biobb_dna/stiffness/basepair_stiffness.py $PREFIX/bin/bpstiff
