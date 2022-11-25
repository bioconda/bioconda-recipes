#! usr/bin/env bash

# for installing conda package
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/bin/lepmap3
mkdir -p $PREFIX/bin/lepanchor
# LepWrap executable
chmod +x LepWrap
cp LepWrap $PREFIX/bin/
# associated scripts
chmod +x scripts/*
cp scripts/* $PREFIX/bin/
# LepMap3 modules and scripts
cp software/LepMap3/*.class $PREFIX/bin/lepmap3
cp software/LepMap3/scripts/* $PREFIX/bin
# LepAnchor modules and scripts
cp software/LepAnchor/*.class $PREFIX/bin/lepanchor
cp software/LepAnchor/scripts/* $PREFIX/bin
cp software/LepAnchor/deps/ucsc_binaries/* $PREFIX/bin
cp software/LepAnchor/deps/*.pl software/LepAnchor/deps/Red software/LepAnchor/deps/all_lastz.ctl software/LepAnchor/deps/scoreMatrix.q software/LepAnchor/deps/step* $PREFIX/bin
# Snakemake rules
cp rules/LepAnchor/*.smk rules/LepMap3/*.smk $PREFIX/bin